var swfu;
var progressBar;
var uploadStarted = false;
var uploadCompleted = false;
var submitPressed = false;
document.observe('dom:loaded', function() {
  when('podcast_title', function(title) {
    var slug = $('podcast_slug'),
        oldTitle = title.value;

    if (!slug) return;

    new Form.Element.Observer(title, 0.15, function() {
      if (oldTitle.toSlug() == slug.value) slug.value = title.value.toSlug();
      oldTitle = title.value;
    });
  });
  
  swfu = new SWFUpload({
    // Backend settings
    upload_url: "/admin/podcasts/episodes/upload?_radiant_session="+encodeURIComponent(_cookie_value)+"&authenticity_token="+encodeURIComponent(_auth_token),
    file_post_name: "upload",
  
    // Flash file settings
    file_size_limit : "25 MB",
    file_types : "*.mp3",
    file_types_description : "MP3s",
    file_upload_limit : "0",
    file_queue_limit : "1",
  
    // Event handler settings
    swfupload_loaded_handler : swfUploadLoaded,
    
    file_dialog_start_handler: fileDialogStart,
    file_queued_handler : fileQueued,
    file_queue_error_handler : fileQueueError,
    file_dialog_complete_handler : fileDialogComplete,
    
    //upload_start_handler : uploadStart,	// I could do some client/JavaScript validation here, but I don't need to.
    upload_progress_handler : uploadProgress,
    upload_error_handler : uploadError,
    upload_success_handler : uploadSuccess,
    upload_complete_handler : uploadComplete,
  
    // Button Settings
    button_image_url : "/images/extensions/podcast/admin/choose-button.png",
    button_placeholder_id : "upload_button",
    button_width: 100,
    button_height: 22,
    
    // Flash Settings
    flash_url : "/javascripts/extensions/podcast/swfupload.swf",
  
    custom_settings : {
      progress_target : "fsUploadProgress",
      upload_successful : false
    },
    
    // Debug settings
    //debug: true
  });
  
});

function swfUploadLoaded() {
  // Custom submit button handling
	$("submit_button").onclick = handleSubmit;
}

function handleSubmit(e) {
	e = e || window.event;
	if (e.stopPropagation) e.stopPropagation();
	e.cancelBubble = true;

  // We only want to submit if the upload hasn't started yet or is complete
  if (!uploadStarted || uploadCompleted) {
		document.forms[0].submit();
    return false;
  }
  // Otherwise mark that the submit button was pressed and disable it so when the upload is complete
  // the form is submitted.
  else {
    submitPressed = true;
    $("submit_button").disable();
  }
	return false;
}

// Called by the queue complete handler to submit the form
function uploadDone() {
  // Flag that the upload has been completed
  // TODO: It'd be nice if this was set if they had validation errors so they don't have to reupload.
  uploadCompleted = true;
  
  // If the submit button was already pressed then we're going to submit the form for the user
  if (submitPressed) {
		document.forms[0].submit();
  }
}

function resetUploadState() {
  if (progressBar) {
    progressBar.dispose();
    progressBar = null;
  }
  $("upload_name").update("");
  $("upload_size").update("");
}

function fileDialogStart() {
  resetUploadState();
	this.cancelUpload(null, false);
  
  // Reset the state of things if a new file is selected
  uploadStarted = false;
  uploadCompleted = false;
  submitPressed = false;
  $("submit_button").enable();
}

function fileQueueError(file, errorCode, message)  {
	try {
		// Handle this error separately because we don't want to create a FileProgress element for it.
		switch (errorCode) {
		case SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED:
			alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
			return;
		case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
			alert("The file you selected is too big.");
			this.debug("Error Code: File too big, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			return;
		case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
			alert("The file you selected is empty.  Please select another file.");
			this.debug("Error Code: Zero byte file, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			return;
		case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
			alert("The file you choose is not an allowed file type.");
			this.debug("Error Code: Invalid File Type, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			return;
		default:
			alert("An error occurred in the upload. Try again later.");
			this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			return;
		}
	} catch (e) {
	}
}

function fileQueued(file) {
  $("upload_name").update(file.name);
  $("upload_size").update(size_format(file.size));
  // Prepare the progress indicator
  if (!progressBar) 
    progressBar = new ProgressBar( $('upload_progress'), {classProgressBar: 'progressBar', style: ProgressBar.DETERMINATE, height: "22", selection: 0, color: {r: 128, g: 128, b: 128}, colorEnd: {r: 32, g: 32, b: 196}, widthIndicators: 2} ); 
}

function fileDialogComplete(numFilesSelected, numFilesQueued) {
	try {
		swfu.startUpload();
    uploadStarted = true;
	} catch (ex) {}
}

function uploadProgress(file, bytesLoaded, bytesTotal) {

  $('upload_progress').show();
  var percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
  progressBar.setSelection(percent);
}

function uploadSuccess(file, serverData) {
  if (serverData == "") {
    this.customSettings.upload_successful = false;
  } else {
    this.customSettings.upload_successful = true;
    upload_id = serverData.split("::")[0];
    duration = duration_values(serverData.split("::")[1]);
    if (duration) {
      $("duration_hours").setValue(duration[0]);
      $("duration_minutes").setValue(duration[1]);
      $("duration_seconds").setValue(duration[2]);
    }

    $("upload_id").value = upload_id;
  }
}

function uploadComplete(file) {
  if (this.customSettings.upload_successful) {
    //this.setButtonDisabled(true);
    uploadDone();
  } else {
    resetUploadState();
    alert("There was a problem with the upload.\nThe server did not accept it.");
  }
}

function uploadError(file, errorCode, message) {
  if (errorCode === SWFUpload.UPLOAD_ERROR.FILE_CANCELLED) {
    // Don't show cancelled error boxes
    return;
  }
  resetUploadState();
  
  // Handle this error separately because we don't want to create a FileProgress element for it.
  switch (errorCode) {
  case SWFUpload.UPLOAD_ERROR.MISSING_UPLOAD_URL:
    alert("There was a configuration error.  You will not be able to upload a resume at this time.");
    this.debug("Error Code: No backend file, File name: " + file.name + ", Message: " + message);
    return;
  case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
    alert("You may only upload 1 file.");
    this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
    return;
  case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
  case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
    break;
  default:
    alert("An error occurred in the upload. Try again later.");
    this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
    return;
  }

  switch (errorCode) {
  case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
    progress.setStatus("Upload Error");
    this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
    break;
  case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
    progress.setStatus("Upload Failed.");
    this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
    break;
  case SWFUpload.UPLOAD_ERROR.IO_ERROR:
    progress.setStatus("Server (IO) Error");
    this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
    break;
  case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
    progress.setStatus("Security Error");
    this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
    break;
  case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
    progress.setStatus("Upload Cancelled");
    this.debug("Error Code: Upload Cancelled, File name: " + file.name + ", Message: " + message);
    break;
  case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
    progress.setStatus("Upload Stopped");
    this.debug("Error Code: Upload Stopped, File name: " + file.name + ", Message: " + message);
    break;
  }
}

function size_format(bytes) {
  a_kilobyte = 1024;
  a_megabyte = a_kilobyte * 1024;
  if (bytes < a_megabyte)
    return (Math.round(bytes / a_kilobyte * 100) / 100) + " KB";
  else
    return (Math.round(bytes / a_megabyte * 100) / 100) + " MB";
};

function duration_values(duration) {
  if (!duration) return [0,0,0];
  dur = Math.floor(duration);
  hours = Math.floor(dur/60/60);
  dur -= hours * 60 * 60;
  minutes = Math.floor(dur/60);
  dur -= minutes * 60;
  seconds = Math.floor(dur);
  return [hours, minutes, seconds];
}


