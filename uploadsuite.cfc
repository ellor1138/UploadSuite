<cfscript>
	component output=false {
		/*
			---------------------------------------------------------------------------------------------------
				Copyright © 2014 Simon Allard
				
				Licensed under the Apache License, Version 2.0 (the "License");
				you may not use this file except in compliance with the License.
				You may obtain a copy of the License at
				
					http://www.apache.org/licenses/LICENSE-2.0
				
				Unless required by applicable law or agreed to in writing, software
				distributed under the License is distributed on an "AS IS" BASIS,
				WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
				See the License for the specific language governing permissions and
				limitations under the License.
			---------------------------------------------------------------------------------------------------
		*/
		
		/* ---------------------------------------------------------------------------------------------------
		 * @hint Constructor
		 * ---------------------------------------------------------------------------------------------------
		*/
		public function init() {
			var loc = {};

			this.version = "1.1.8,1.3";

			application.uploadsuite = {};
			application.uploadsuite = $initUploadSuitePluginSettings();

			return this;
		}

		/* ---------------------------------------------------------------------------------------------------
		 * @hint Return plugin settings
		 * ---------------------------------------------------------------------------------------------------
		*/
		public struct function getUploadSuiteSettings() {
			return application.uploadsuite;
		}

		/* ---------------------------------------------------------------------------------------------------
		 * @hint Standard File Upload
		 * ---------------------------------------------------------------------------------------------------
		*/
		public any function fileUploadTag(
			string uuid="#GetTickCount()#",
			string route="",
			string controller="",
			string action="",
			string destination="",
			string fileName="",
			string nameConflict="makeUnique",
			string id="file-field-#arguments.uuid#",
			string label="Select a file to upload",
			string labelFileName="Name: ",
			string labelFileSize="Size: ",
			string labelFileType="Type: ",
			string labelUploadButton="Upload",
			string messageLoading="Loading...",
			string messageSuccess="File uploaded successfully!",
			string messageError="An error occured, please try again.",
			string messageBadFileType="This file is not allowed!",
			string class="upload-suite-container",
			string style="",
			string classSuccess="upload-suite-success",
			string classError="upload-suite-error",
			string fileFieldName="file-#arguments.uuid#",
			string mimeTypesList="#application.uploadsuite.settings.UploadSuiteMimeTypesList#",
			string localeid=""
			) {
			var loc = {};

			// writeDump(arguments);
			// abort;

			// Create URL ---------------------------------------------------------------------
			if ( Len(arguments.route) || Len(arguments.controller) || Len(arguments.action) ) {
				arguments.url = URLFor(argumentCollection=arguments);
			}

			// Translate labels with Localizator plugin
			// ---> https://github.com/ellor1138/Localizator
			// ---> http://cfwheels.org/plugins/listing/89
			if ( Len(arguments.localeid) ) {
				loc.args = "label,labelFileName,labelFileSize,labelFileType,labelUploadButton,messageLoading,messageSuccess,messageError,messageBadFileType";

				for (loc.i=1; loc.i<=ListLen(loc.args); loc.i++) {
					arguments[ListGetAt(loc.args, loc.i)] = l(arguments[ListGetAt(loc.args, loc.i)]);
				}
			}
			// --------------------------------------------------------------------------------

			// Upload container ---------------------------------------------------------------
			loc.uc = "
				<script type='text/javascript'>
					var #toScript(arguments.uuid, 'id#arguments.uuid#')#
				</script>
				<div class='#arguments.class#' style='#arguments.style#'>
					<div class='form-elements-container'>
						<label for='#arguments.id#'>#arguments.label#</label>

						<input type='file' name='#arguments.fileFieldName#' id='#arguments.id#' onchange='fileSelected#arguments.uuid#(id#arguments.uuid#);'/><br />
						<input type='button' value='#arguments.labelUploadButton#' onclick='uploadFile#arguments.uuid#(id#arguments.uuid#)' id='upload-button-#arguments.uuid#' disabled=true />
					</div>

					<div class='file-info-container' id='file-selected-#arguments.uuid#'>
						<div id='file-name-#arguments.uuid#'></div>
						<div id='file-size-#arguments.uuid#'></div>
						<div id='file-type-#arguments.uuid#'></div>
						<div id='message-#arguments.uuid#'></div>
					</div>
					
					<div class='progress-container' id='progress-container-#arguments.uuid#'>
						<div class='progress-bar' id='progress-bar-#arguments.uuid#'>
							<div class='progress-indicator' id='progress-indicator-#arguments.uuid#'></div>
						</div>
						<div class='progress-number' id='progress-number-#arguments.uuid#'>100%</div>
					</div>
				</div>
			";
			// --------------------------------------------------------------------------------

			loc.js = "";
			
			loc.uc = "<div id='file-upload-#arguments.uuid#'>" & loc.uc & loc.js & "</div>";

			return loc.uc;
		}
		
		
		/* ---------------------------------------------------------------------------------------------------
		 * @hint Ajax File Upload
		 * ---------------------------------------------------------------------------------------------------
		*/
		public function ajaxFileUploadTag(
			string uuid="#GetTickCount()#",
			string route="",
			string controller="",
			string action="",
			string params="",
			string destination="",
			string fileName="",
			string nameConflict="makeUnique",
			string id="file-field-#arguments.uuid#",
			string label="Select a file to upload",
			string labelFileName="Name: ",
			string labelFileSize="Size: ",
			string labelFileType="Type: ",
			string labelUploadButton="Upload",
			string messageLoading="Loading...",
			string messageSuccess="File uploaded successfully!",
			string messageError="An error occured, please try again.",
			string messageBadFileType="This file is not allowed!",
			string class="upload-suite-container",
			string style="",
			string classSuccess="upload-suite-success",
			string classError="upload-suite-error",
			string fileFieldName="file-#arguments.uuid#",
			string mimeTypesList="#application.uploadsuite.settings.UploadSuiteMimeTypesList#",
			string localeid="",
			string waitingMessage="",
			struct selectForm={},
			string section="",
			boolean reload=false,
			boolean minimalist=false
			) {
			var loc = {};

			// writeDump(arguments);
			// abort;

			// Create URL ---------------------------------------------------------------------
			if ( Len(arguments.route) || Len(arguments.controller) || Len(arguments.action) ) {
				arguments.url = URLFor(argumentCollection=arguments);
			}

			// Translate labels with Localizator plugin
			// ---> https://github.com/ellor1138/Localizator
			// ---> http://cfwheels.org/plugins/listing/89
			if ( Len(arguments.localeid) ) {
				loc.args = "label,labelFileName,labelFileSize,labelFileType,labelUploadButton,messageLoading,messageSuccess,messageError,messageBadFileType";

				for (loc.i=1; loc.i<=ListLen(loc.args); loc.i++) {
					arguments[ListGetAt(loc.args, loc.i)] = l(arguments[ListGetAt(loc.args, loc.i)]);
				}
			}
			// --------------------------------------------------------------------------------

			if ( !arguments.minimalist ) {
				if ( StructKeyExists(arguments, 'selectForm') AND StructKeyExists(arguments.selectForm, 'label') ) {
					arguments.selectForm = selectTag(name='option-#arguments.uuid#', id="selectForm", argumentCollection=arguments.selectForm, style="margin-bottom:10px;");
				} else {
					arguments.selectForm = "";
				}
				// Upload container ---------------------------------------------------------------
				loc.uc = "
					<script type='text/javascript'>
						var #toScript(arguments.uuid, 'id#arguments.uuid#')#
					</script>
					<div class='#arguments.class#' style='#arguments.style#'>
						<div class='form-elements-container'>
							#arguments.selectForm#

							<label for='#arguments.id#'>#arguments.label#</label>

							<input type='file' name='#arguments.fileFieldName#' id='#arguments.id#' onchange='fileSelected#arguments.uuid#(id#arguments.uuid#);'/><br />
							<input type='button' value='#arguments.labelUploadButton#' onclick='uploadFile#arguments.uuid#(id#arguments.uuid#)' id='upload-button-#arguments.uuid#' disabled=true />
						</div>

						<div class='file-info-container' id='file-selected-#arguments.uuid#'>
							<div id='file-name-#arguments.uuid#'></div>
							<div id='file-size-#arguments.uuid#'></div>
							<div id='file-type-#arguments.uuid#'></div>
							<div id='message-#arguments.uuid#'></div>
						</div>
						
						<div class='progress-container' id='progress-container-#arguments.uuid#'>
							<div class='progress-bar' id='progress-bar-#arguments.uuid#'>
								<div class='progress-indicator' id='progress-indicator-#arguments.uuid#'></div>
							</div>
							<div class='progress-number' id='progress-number-#arguments.uuid#'>100%</div>
						</div>
					</div>
				";
				// --------------------------------------------------------------------------------

				// JavaScript ---------------------------------------------------------------------
				loc.js = "
					<script type='text/javascript'>
						function fileSelected#arguments.uuid#(uuid) {
							var file = document.getElementById('#arguments.id#').files[0];

							document.getElementById('progress-container-'+uuid).style.display = 'none';

							if ( file ) {
								var #toScript(arguments.mimeTypesList, 'mimeTypesList')#

								if ( file.type && mimeTypesList.indexOf(file.type) >= 0 ) {
									var fileSize = 0;
									
									if ( file.size > 1024 * 1024 ) {
										fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
									
									} else {
										fileSize = (Math.round(file.size * 100 / 1024) / 100).toString() + 'KB';
									}

									setMessage#arguments.uuid#(uuid);
									setFileInfo#arguments.uuid#(uuid, file, fileSize);
									document.getElementById('upload-button-'+uuid).disabled = false;
								
								} else {
									setMessage#arguments.uuid#(uuid, 'badFileType');
									setFileInfo#arguments.uuid#(uuid, file);
									document.getElementById('upload-button-'+uuid).disabled = true;
								}
							
							} else {
								setFileInfo#arguments.uuid#(uuid);
								document.getElementById('upload-button-'+uuid).disabled = true;
							}
						}

						function setFileInfo#arguments.uuid#(uuid, file, fileSize) {
							document.getElementById('file-selected-'+uuid).style.display = 'none';
							document.getElementById('file-name-'+uuid).innerHTML = '';
							document.getElementById('file-size-'+uuid).innerHTML = '';
							document.getElementById('file-type-'+uuid).innerHTML = '';

							if ( file ) {
								document.getElementById('file-selected-'+uuid).style.display = 'block';

								if ( file.name ) {
									document.getElementById('file-name-'+uuid).innerHTML = '#arguments.labelFileName#' + file.name;
								}

								if ( fileSize ) {
									document.getElementById('file-size-'+uuid).innerHTML = '#arguments.labelFileSize#' + fileSize;
								}

								if ( file.type ) {
									document.getElementById('file-type-'+uuid).innerHTML = '#arguments.labelFileType#' + file.type;
								}
							}
						}

						function setMessage#arguments.uuid#(uuid, messageType, message) {
							// console.log(uuid);
							document.getElementById('message-'+uuid).innerHTML = '';
							document.getElementById('message-'+uuid).className = '';

							switch(messageType) {
								case 'custom-success':
									document.getElementById('message-'+uuid).innerHTML = message;
									document.getElementById('message-'+uuid).className = '#arguments.classSuccess#';
									break;

								case 'custom-error':
									document.getElementById('message-'+uuid).innerHTML = message;
									document.getElementById('message-'+uuid).className = '#arguments.classError#';
									break;

								case 'success':
									document.getElementById('message-'+uuid).innerHTML = '#arguments.messageSuccess#';
									document.getElementById('message-'+uuid).className = '#arguments.classSuccess#';
									break;

								case 'error':
									document.getElementById('message-'+uuid).innerHTML = '#arguments.messageError#';
									document.getElementById('message-'+uuid).className = '#arguments.classError#';
									break;

								case 'badFileType':
									document.getElementById('message-'+uuid).innerHTML = '#arguments.messageBadFileType#';
									document.getElementById('message-'+uuid).className = '#arguments.classError#';
									break;
							}
						}

						function uploadFile#arguments.uuid#(uuid) {
							var fd#arguments.uuid#  = new FormData();
							var xhr#arguments.uuid# = new XMLHttpRequest();

							if ( #Len(arguments.fileName)# ) {
								fd#arguments.uuid#.append('fileName', '#arguments.fileName#');
							}

							if ( #Len(arguments.destination)# ) {
								fd#arguments.uuid#.append('destination', '#arguments.destination#');
							}

							if ( #Len(arguments.selectForm)# ) {
								var e = document.getElementById('selectForm');
								var o = e.options[e.selectedIndex].value;
								fd#arguments.uuid#.append('uploadtypeid', o);	
							}

							fd#arguments.uuid#.append('nameConflict', '#arguments.nameConflict#');
							fd#arguments.uuid#.append('fileFieldName', '#arguments.fileFieldName#');
							fd#arguments.uuid#.append('mimeTypesList', '#arguments.mimeTypesList#');
							fd#arguments.uuid#.append('#arguments.fileFieldName#', document.getElementById('#arguments.id#').files[0]);


							xhr#arguments.uuid#.upload.addEventListener('progress', function(evt) {
								if ( evt.lengthComputable ) {
									var percentComplete = Math.round(evt.loaded * 100 / evt.total);

									document.getElementById('progress-indicator-'+uuid).style.width = percentComplete.toString() + '%';
									document.getElementById('progress-number-'+uuid).innerHTML = percentComplete.toString() + '%';
								
								} else {
									document.getElementById('progress-number-'+uuid).innerHTML = 'unable to compute';
								}
							});

							xhr#arguments.uuid#.upload.addEventListener('loadstart', function(e) {
								document.getElementById('progress-container-'+uuid).style.display = 'block';
							});

							xhr#arguments.uuid#.addEventListener('error', uploadFailed#arguments.uuid#, false);

							xhr#arguments.uuid#.onreadystatechange = function(aEvt) {
								if ( xhr#arguments.uuid#.readyState == 4 ) {
									if ( xhr#arguments.uuid#.status == 200 ) {
										try {
											var responseJSON = JSON.parse(xhr#arguments.uuid#.responseText);

											if ( responseJSON.FILEWASSAVED ) {
												if ( responseJSON.RESULT ) {
													setMessage#arguments.uuid#(uuid, 'custom-success', responseJSON.MESSAGE);

													if ( responseJSON.REPLACE ) {
														$('##'+responseJSON.CONTENTID).empty();
														$('##'+responseJSON.CONTENTID).append(responseJSON.CONTENT);
													}

													if ( responseJSON.GROWL ) {
														$('body').append(responseJSON.GROWL);
													}

													if ( responseJSON.RELOAD ) {
														window.setTimeout(function(){location.reload()},1000);
													}

													if ( responseJSON.ADDFILE ) {
														$('##files tr:last').after(responseJSON.TABLEROW);
													}
												
												} else {
													setMessage#arguments.uuid#(uuid, 'custom-error', responseJSON.MESSAGE);
												}
												document.getElementById('progress-container-'+uuid).style.display = 'none';

											} else {
												setMessage#arguments.uuid#(uuid, 'error');
												document.getElementById('progress-container-'+uuid).style.display = 'none';
											}
										}

										catch(e) {
											setMessage#arguments.uuid#(uuid, 'error');
											document.getElementById('progress-container-'+uuid).style.display = 'none';
										}
									
									} else {
										setMessage#arguments.uuid#(uuid, 'error');
										document.getElementById('progress-container-'+uuid).style.display = 'none';
									}
								}
							};

							xhr#arguments.uuid#.open('POST', '#arguments.url#');
							xhr#arguments.uuid#.send(fd#arguments.uuid#);
						}

						function uploadFailed#arguments.uuid#(uuid, evt) {
							setMessage(uuid, 'error');
						}
					</script>
				";
				// --------------------------------------------------------------------------------
			
			} else {
				loc.uc = "";
				loc.js = "";
			}

			loc.uc = "<div id='file-upload-#arguments.uuid#'>" & loc.uc & loc.js & "</div>";

			return loc.uc;
		}

		/* ---------------------------------------------------------------------------------------------------
		/* "PRIVATE" FUNCTIONS
		/* ---------------------------------------------------------------------------------------------------
		/* ---------------------------
		 * @hint Init plugin settings
		 * ---------------------------
		*/
		public function $initUploadSuitePluginSettings() {
			var loc  = {};
			var temp = {};

			// Set application wheels path
			if ( StructKeyExists(application, "$wheels") ) {
				temp.wheels      = "$wheels";
				temp.application = application.$wheels;

			} else if (StructKeyExists(application, "wheels") ) {
				temp.wheels      = "wheels";
				temp.application = application.wheels;
			}

			// Create list of accepted mime type from wheels default mime type and format
			// Only if thers's no list supplied by user in config/settings
			if ( !StructKeyExists(temp.application, "UploadSuiteMimeTypesList") ) {
				temp.lhs = CreateObject("java", "java.util.LinkedHashSet");

				temp.UploadSuiteMimeTypesList = "";

				// Create list from wheels mime type
				for ( temp.key IN temp.application["mimetypes"] ) {
					temp.UploadSuiteMimeTypesList = ListAppend(temp.UploadSuiteMimeTypesList, temp.application["mimetypes"][temp.key]);
				}

				// Create list from wheels format
				for ( temp.key IN temp.application["formats"] ) {
					temp.UploadSuiteMimeTypesList = ListAppend(temp.UploadSuiteMimeTypesList, temp.application["formats"][temp.key]);
				}

				// Remove duplicate
				temp.UploadSuiteMimeTypesList = ArrayToList(temp.lhs.init(ListToArray(temp.UploadSuiteMimeTypesList)).toArray());
			}

			// Remove banned mime type
			if ( StructKeyExists(temp.application, "uploadSuiteBannedMimeTypes") ) {
				for ( temp.key = 1; temp.key <= ListLen(temp.application[uploadSuiteBannedMimeTypes]); temp.key++ ) {
					if ( ListFind(temp.UploadSuiteMimeTypesList, ListGetAt(temp.application["uploadSuiteBannedMimeTypes"], temp.key)) ) {
						temp.UploadSuiteMimeTypesList = ListDeleteAt(temp.UploadSuiteMimeTypesList, ListFind(temp.UploadSuiteMimeTypesList, ListGetAt(temp.application["uploadSuiteBannedMimeTypes"], temp.key)));
					}
				}
			}

			// Plugin info
			loc.plugin = {};
			loc.plugin.author        = "Simon Allard";
			loc.plugin.name          = "UploadSuite";
			loc.plugin.version       = "1.1";
			loc.plugin.compatibility = "1.1.8, 1.3";
			loc.plugin.project       = "https://github.com/ellor1138/UploadSuite";
			loc.plugin.documentation = "https://github.com/ellor1138/UploadSuite/wiki";
			loc.plugin.issues        = "https://github.com/ellor1138/UploadSuite/issues";

			loc.settings.UploadSuiteMimeTypesList = temp.UploadSuiteMimeTypesList;

			return loc;
		}
	}
</cfscript>