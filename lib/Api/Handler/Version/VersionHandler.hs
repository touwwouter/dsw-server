module Api.Handler.Version.VersionHandler where

import Control.Monad.Trans.Class (lift)
import Network.HTTP.Types.Status (created201)
import Web.Scotty.Trans (json, param, status)

import Api.Handler.Common
import Service.Package.PackageService

putVersionA :: Endpoint
putVersionA =
  checkPermission "KM_PUBLISH_PERM" $
  getReqDto $ \reqDto -> do
    branchUuid <- param "branchUuid"
    version <- param "version"
    eitherDto <- lift $ createPackageFromKMC branchUuid version reqDto
    case eitherDto of
      Right dto -> do
        status created201
        json dto
      Left error -> sendError error
