mod = angular.module "starter.controllers"

mod.controller "mmLedMeditationController", ($scope, $stateParams, $ionicLoading, mmMeditationData) ->
  media = null
  mediaTimer = null
  
  meditationObject = mmMeditationData.getMeditationById($stateParams.meditationId)  
  categoryObject = mmMeditationData.getCategoryById(meditationObject.parentId)
  $scope.pageTitle = meditationObject.title
  $scope.categoryTitle = categoryObject.title
  
  $scope.description = categoryObject.description
  
  #media defaults
  $scope.isPlaying = false
  $scope.duration = meditationObject.duration #media.getDuration() returns -1 even when media is ready!
  $scope.position = 0
  
  insomniaSucc = ->
    console.log 'insomnia success'
  insomniaError = (e) ->
    alert 'insomnia error', e
  
  $scope.play = ->
    media.play() if media
    window.plugins?.insomnia?.keepAwake insomniaSucc insomniaError
  $scope.pause = ->
    media.pause() if media
    window.plugins?.insomnia?.allowSleepAgain insomniaSucc insomniaError
  
  #clear up resources on leaving page
  $scope.$on "$ionicView.beforeLeave", ->
    console.log "$ionicView.beforeLeave"
    if media
      media.stop()
      media.release()
    clearInterval mediaTimer if mediaTimer
    window.plugins?.insomnia?.allowSleepAgain insomniaSucc insomniaError
  
  if ionic.Platform.isWebView()
    ionic.Platform.ready ->
      
      mediaError = (e) ->
        console.log "Media Error!"
        console.log JSON.stringify e
      
      changeMediaStatus = (s) ->        
        if s == Media.MEDIA_RUNNING
          $scope.isPlaying = true
        else
          $scope.isPlaying = false
        if s == Media.MEDIA_STARTING
          $ionicLoading.show {template: 'Loading...'}
        else
          $ionicLoading.hide()
        
        console.log "media status change", s, $scope.isPlaying, media.getDuration()
      
      #get media URL from service (async)
      mmMeditationData.getMediaURL(meditationObject.id).then (mediaURL) ->
        debugger
        media = new Media mediaURL, null, mediaError, changeMediaStatus
      
        #getCurrentPosition timer
        successCb = (position) ->
          if position > -1
            $scope.position = parseInt(position)
            $scope.$apply()
        errorCb = (e) ->
          console.log "Error getting position", e
        
        intervalFunction = ->
          media.getCurrentPosition successCb, errorCb
        
        mediaTimer = setInterval intervalFunction, 500
      
  else
    console.log "running in web browser"
    #todo: brower html5 audio version