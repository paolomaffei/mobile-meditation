mod = angular.module "starter.controllers"

mod.controller "mmDownloadController", ($scope, $stateParams, $ionicLoading, mmMeditationData, mmFileSystem) ->
    
  downloadFile = (fileName, URL) ->
    $ionicLoading.show {
      template: "Downloading " + fileName
    }
        
    dirEntrySuccess = (fileEntry) ->
      console.log "dir entry success"
      fileEntryToURL = fileEntry.toURL()
      fileEntry.remove()
      ft = new FileTransfer()
      
      encodedURL = encodeURI URL 
      
      downloadSuccess = (entry) ->
        console.log "download success"
        $ionicLoading.hide();
        $scope.imgFile = entry.toURL();

      downloadFail = (error) ->
        console.log "download failed", error.source
      
      ft.download encodedURL, fileEntryToURL, downloadSuccess, downloadFail, false, null
    
    dirEntryFail = ->
      console.log "dir entry failed"
    
    getDirectorySuccess = (dirEntry) ->
      dirEntry.getFile fileName, {create: true, exclusive: false}, dirEntrySuccess, dirEntryFail
    
    debugger
    mmFileSystem.getFsDirectory "mobileMeditationData", getDirectorySuccess
  
  $scope.imgFile = null
  
  $scope.download = ->
    baseURL = "http://www.freebuddhistmeditation.com/bw-mp3s/"
    
    medits = mmMeditationData.getMeditations()
    
    downloadFile(medits[0].id + ".mp3", baseURL + medits[0].id + ".mp3")
    