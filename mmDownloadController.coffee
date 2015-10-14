mod = angular.module "starter.controllers"

mod.controller "mmDownloadController", ($scope, $stateParams, $ionicLoading, mmMeditationData, mmFileSystem) ->
  
  $scope.imgFile = null
    
  $scope.download = () ->
    $ionicLoading.show {
      template: 'Loading...'
    }
        
    dirEntrySuccess = (fileEntry) ->
      fileEntryToURL = fileEntry.toURL()
      fileEntry.remove()
      ft = new FileTransfer()
      
      downloadURL = encodeURI "http://ionicframework.com/img/ionic-logo-blog.png" 
      
      downloadSuccess = (entry) ->
        console.log "download success"
        $ionicLoading.hide();
        $scope.imgFile = entry.toURL();

      downloadFail = (error) ->
        console.log "download failed", error.source
      
      ft.download downloadURL, fileEntryToURL, downloadSuccess, downloadFail, false, null
    
    dirEntryFail = ->
      console.log "dir entry failed"
    
    getDirectorySuccess = (dirEntry) ->
      dirEntry.getFile "test.png", {create: true, exclusive: false}, dirEntrySuccess, dirEntryFail
    
    debugger
    mmFileSystem.getFsDirectory "mobileMeditationData", getDirectorySuccess

    