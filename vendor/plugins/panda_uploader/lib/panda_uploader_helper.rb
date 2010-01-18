module PandaUploaderHelper
  
  def js_panda_uploader_init(pu_options={})

    options = { 
      :name => "swfu",
      :button_image_url => "/images/DefaultUploaderButton.png",
      :button_placeholder_id => "spanButtonPlaceholder",
      :button_width => "61",
      :button_height => "22",
      :button_placeholder_id => "spanButtonPlaceholder",
      :flash_url => "/swfupload.swf",
      :upload_url => Panda.api_url + "/videos.json",
      :upload_post_params => {},
      :server_data_id => "video",
      :submit_id => 'btnSubmit',
      :debug => false
    }.merge(pu_options)

    plugins = []
    state_update_url_include = <<-end_eval
      addParamsToPanda('state_update_url', "#{options[:state_update_url]}")
    end_eval
    
    plugins << state_update_url_include unless options[:state_update_url].to_s.empty?
    
    src = <<-end_eval
    
     // Hack to get CustomSetting ... maybe a better way
     SWFUpload.prototype.getCustomSettings = function () {
     	return this.customSettings
     };

      var swfu;
      window.onload = function () {
      	swfu = new SWFUpload({
      		upload_url: "#{options[:upload_url]}",
      		file_post_name: "file",
      		post_params : {},

      		// Flash file settings
      		file_size_limit : "100 MB",
      		file_types : "*.*",			// or you could use something like: "*.doc;*.wpd;*.pdf",
      		file_types_description : "All Files",
      		file_upload_limit : "0",
      		file_queue_limit : "1",

      		// Event handler settings
      		swfupload_loaded_handler : swfUploadLoaded,

      		file_dialog_start_handler: fileDialogStart,
      		file_queued_handler : fileQueued,
      		file_queue_error_handler : fileQueueError,
      		file_dialog_complete_handler : fileDialogComplete,

      		upload_start_handler : uploadStart,	// I could do some client/JavaScript validation here, but I don't need to.
      		upload_progress_handler : uploadProgress,
      		upload_error_handler : uploadError,
      		upload_success_handler : uploadSuccess,
      		upload_complete_handler : uploadComplete,

      		// Button Settings
      		button_image_url : "#{options[:button_image_url]}",
      		button_placeholder_id : "#{options[:button_placeholder_id]}",
      		button_width: #{options[:button_width]},
      		button_height: #{options[:button_height]},

      		// Flash Settings
      		flash_url : "#{options[:flash_url]}",

      		custom_settings : {
      			progress_target : "fsUploadProgress",
      			upload_successful : false,
      			upload_data_id: '#{options[:server_data_id]}',
      			submit_id: '#{options[:submit_id]}'
      		},

      		// Debug settings
      		debug: #{options[:debug]}

      	});
      };

      function uploadStart(file) {

          // required params to authenticate
      		var req_params = {
      		  'authenticity_token': '#{form_authenticity_token}',
      		  'request_uri': '/videos.json',
      		  'method': 'post',
      		};
      		
      		var flash_params = {}
      		
      		// Use to add params to panda api post request
      		addParamsToPanda = function (key, value) {
        		jQuery.extend(req_params, prefix_query('request_params['+key+']',value))
        		jQuery.extend(flash_params, prefix_query(key, value))            
          }
          
      		// Get authentication params
      		getAuthParams = function() {
      		  jQuery.ajax({
        	           dataType: "json",
                     url: '/authentication_params',
                     data: req_params,
                     async: false,
                     success: function(data) {
                       jQuery.extend(flash_params, data)
                     }
            });
      		}
      		
          // plugins to add params for example 
          #{plugins.join(' ')}
          
      		// Add selected encodings
      		addParamsToPanda('profiles', getPandaVideoProfiles())

          // get panda auth params
          getAuthParams()
          
          this.setPostParams(flash_params);
          return true;
      }

      function uploadSuccess(file, serverData) {
      	try {
      		file.id = "singlefile";	// This makes it so FileProgress only makes a single UI element, instead of one for each file
      		var progress = new FileProgress(file, this.customSettings.progress_target);
      		progress.setComplete();
      		progress.setStatus("Complete.");
      		progress.toggleCancel(false);

      		if (serverData === " ") {
      			this.customSettings.upload_successful = false;
      		} else {
      			this.customSettings.upload_successful = true;
      			
      			// Insert the server Data inside an input
      			document.getElementById("#{options[:server_data_id]}").value = serverData;
      		}

      	} catch (e) {
      	}
      }

      
      // Can be overided to appy a different behaviour
      function uploadDone(file) {
        serverData = document.getElementById("#{options[:server_data_id]}").value
        window.location = "/videos/"+JSON.parse(serverData).id+"/processing";     
      }

      end_eval
    
    javascript_tag src
    
  end
  
  def panda_uploader_profile_selector()
    profiles_json = Panda.get("/profiles.json")

    unless profiles_json.nil?
      profiles = JSON.parse(profiles_json)
      
      src=''
      if profiles
    		profiles.each_with_index do |p,i|
    		  src += <<-end_eval
    			<p>
    				<input type="checkbox" name="profiles[#{i}]" panda_input_type="profile_input" profile_id="#{p['id']}" value="#{p['id']}" > #{p['title']}
    			</p>
  			  end_eval
    		end
    	end
      src
    end
  end
  
  
  def panda_uploader_file_selector(pu_options={})
    options = { 
      :name => "swfu",
    }.merge(pu_options)
    
    src = <<-end_eval
      <span id="spanButtonPlaceholder"></span>      
      <input type="text" id="txtFileName" disabled="true" style="border: solid 1px; background-color: #FFFFFF;" />
      <div class="flash" id="fsUploadProgress"></div>
    end_eval
    
  end
	
	
  def javascript_include_panda_uploader
    javascript_include_tag 'panda_uploader/panda_uploader.js', 'panda_uploader/fileprogress', 'panda_uploader/swfupload', 'panda_uploader/handlers', 'panda_uploader/swfupload.swfobject', 'panda_uploader/monitor_progress'
  end
  
end