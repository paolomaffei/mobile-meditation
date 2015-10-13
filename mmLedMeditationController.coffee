mod = angular.module "starter.controllers"

mod.controller "mmLedMeditationController", ($scope, $stateParams, $ionicLoading, tmMeditationData) ->
  media = null
  mediaTimer = null
  
  meditationObject = tmMeditationData.getMeditationById($stateParams.meditationId)  
  categoryObject = tmMeditationData.getCategoryById(meditationObject.parentId)
  $scope.pageTitle = meditationObject.title
  $scope.categoryTitle = categoryObject.title
  
  audioSrc = "resources/" + tmMeditationData.getResourceFolder() + "/" + meditationObject.id + ".mp3"
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
      
      getMediaURL = (s) ->
        if ionic.Platform.isAndroid() then return "/android_asset/www/" + s
        else return s
      
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
      
      media = new Media getMediaURL(audioSrc), null, mediaError, changeMediaStatus
      
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