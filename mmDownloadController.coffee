mod = angular.module "starter.controllers"

mod.controller "mmDownloadController", ($scope, $stateParams, $ionicLoading, mmMeditationData, mmDownloads) ->
  
  baseURL = mmMeditationData.getBaseURL()
  
  $scope.meditations = mmMeditationData.getMeditations()
  
  $scope.downloadAll = ->
    _.each meditations, (m) ->
      $scope.download m
  
  $scope.download = (m) ->
    $scope.downloadId = m.id
    $scope.downloadProgress = 0
    
    mmDownloads.downloadFile(m.id + ".mp3", baseURL + m.id + ".mp3").then( (internalURL) ->
      debugger
      m.downloaded = internalURL
      delete $scope.downloadId
      delete $scope.downloadProgress
      $scope.$apply()
    ).catch( (e )->
      debugger
      console.log e
      $scope.downloadProgress = "failed, try again"
      $scope.$apply()
    ).then(null, null, (progress) -> #notify cb
      $scope.downloadProgress = progress
      console.log progress
    )
    
  $scope.getDownloadedIcon = (meditation) ->
    if meditation.downloaded then "icon icon-green ion-android-checkbox" else "icon icon-red ion-android-close"
    