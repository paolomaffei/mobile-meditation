mod = angular.module "starter.controllers"

mod.controller "mmDownloadController", ($scope, $stateParams, $ionicLoading, mmMeditationData, mmDownloads, $q) ->
  
  baseURL = mmMeditationData.getBaseURL()
  
  download = (m) ->
    defer = $q.defer()
    
    if m.downloaded
      console.log m.id, "already downloaded"
      defer.resolve()
      
    $scope.downloadId = m.id
    $scope.downloadProgress = 0
    
    mmDownloads.downloadFile(m.id + ".mp3", baseURL + m.id + ".mp3").then( (internalURL) ->
      m.downloaded = internalURL
      delete $scope.downloadId
      delete $scope.downloadProgress
      defer.resolve()
    ).catch( (e )->
      console.log e
      $scope.downloadProgress = "failed, try again"
      defer.reject()
    ).then(null, null, (progress) -> #notify cb
      $scope.downloadProgress = progress + "%"
    )
    
    return defer.promise #for use by $scope.downloadAll
  
    
  $scope.meditations = mmMeditationData.getMeditations()
  
  #downloads all files in sequence (one by one)
  $scope.downloadAll = ->
    i = 0
    doDownload = ->
      download($scope.meditations[i]).then(downloadNext)
    
    #download one file, and when finished, download the next one
    downloadNext = ->
      console.log "downloadNext ", i
      #until there are indexes to download
      if i < $scope.meditations.length
        doDownload()
      else
        console.log "finished download everything"
      i++
      
    #start the downloads
    downloadNext()
  
  $scope.download = (m) ->
    download m #do nothing with the returned promise
      
  $scope.getDownloadedIcon = (meditation) ->
    if meditation.downloaded then "icon icon-green ion-android-checkbox" else "icon icon-red ion-android-close"