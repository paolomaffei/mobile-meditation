mod = angular.module "starter.controllers"

mod.controller "mmDownloadController", ($scope, $stateParams, $state, $ionicLoading, mmMeditationData, mmDownloads, $q) ->
  
  baseURL = mmMeditationData.getBaseURL()
  
  download = (m) ->
    defer = $q.defer()
    
    if m.downloaded
      console.log m.id, "already downloaded"
      defer.resolve()
      
    $scope.downloadId = m.id
    $scope.downloadProgress = "0%"
    
    mmDownloads.downloadFile(m.id + ".mp3", baseURL + m.id + ".mp3").then( (internalURL) ->
      m.downloaded = internalURL
      delete $scope.downloadId
      delete $scope.downloadProgress
      defer.resolve()
    ).catch( (e )->
      console.log e
      $scope.downloadProgress = "failed, try again"
      
      #re-enable download all button
      $scope.disableDownloadAll = false
      defer.reject()
    ).then(null, null, (progress) -> #notify cb
      $scope.downloadProgress = progress + "%"
    )
    
    return defer.promise #for use by $scope.downloadAll
  
  #scope 
  $scope.meditations = mmMeditationData.getMeditations()
  
  #if at least one meditation has already been downloaded
  #for m in $scope.meditations
  #  if m.downloaded
      #disable "download all"" button
  #    $scope.disableDownloadAll = true;
  
  #downloads all files in sequence (one by one)
  $scope.downloadAll = ->
    i = 0
    doDownload = ->
      download($scope.meditations[i]).then(downloadNext)
    
    #disable download all button
    $scope.disableDownloadAll = true;
    
    #download one file, and when finished, download the next one
    downloadNext = ->
      console.log "downloadNext ", i
      #until there are indexes to download
      if i < $scope.meditations.length
        doDownload()
      else #this only happens when even the last file has been downloaded succesfully
        console.log "finished downloading everything"
        $state.go "app.categories"
      i++
      
    #start the downloads
    downloadNext()
  
  $scope.download = (m) ->
    download m #do nothing with the returned promise
      
  $scope.getDownloadedIcon = (meditation) ->
    if meditation.downloaded then "icon icon-green ion-android-checkbox" else "icon icon-red ion-android-close"