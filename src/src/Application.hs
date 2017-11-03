module Application where

import Control.Lens ((^.))
import Control.Monad.Except
import Data.Text
import Database.Persist.MongoDB (withMongoDBConn)
import Network
import Text.Regex
import Web.Scotty

import Api.Handler.Common
import Api.Handler.Event.EventHandler
import Api.Handler.Info.InfoHandler
import Api.Handler.KnowledgeModel.KnowledgeModelHandler
import Api.Handler.KnowledgeModelContainer.KnowledgeModelContainerHandler
import Api.Handler.Token.TokenHandler
import Api.Handler.User.UserHandler
import Api.Middleware.Auth
import Api.Middleware.CORS
import Context
import DSPConfig
import Migration

unauthorizedEndpoints = [mkRegex "^$", mkRegex "^tokens$"]

runApplication context dspConfig =
  let serverPort = dspConfig ^. dspcfgWebConfig ^. acwPort
  in scotty serverPort $ do
       middleware corsMiddleware
       middleware (authMiddleware dspConfig unauthorizedEndpoints)
       get "/" (getInfoA context dspConfig)
       post "/tokens" (postTokenA context dspConfig)
       
       get "/users" (getUsersA context dspConfig)
       post "/users/" (postUsersA context dspConfig)
       get "/users/current" (getUserCurrentA context dspConfig)
       get "/users/:userUuid" (getUserA context dspConfig)
       put "/users/current" (putUserCurrentA context dspConfig)
       put "/users/:userUuid" (putUserA context dspConfig)
       delete "/users/:userUuid" (deleteUserA context dspConfig)
       
       get "/kmcs" (getKnowledgeModelContainersA context dspConfig)
       post "/kmcs" (postKnowledgeModelContainersA context dspConfig)
       get "/kmcs/:kmcUuid" (getKnowledgeModelContainerA context dspConfig)
       put "/kmcs/:kmcUuid" (putKnowledgeModelContainerA context dspConfig)
       delete "/kmcs/:kmcUuid" (deleteKnowledgeModelContainerA context dspConfig)
       
      --  get "/kmcs/:kmUuid/km" (getKnowledgeModelA context dspConfig)
       
      --  get "/kmcs/:kmUuid/events" (getEventsA context dspConfig)
      --  post "/kmcs/:kmUuid/events/_bulk" (postEventsA context dspConfig)
      --  delete "/kmcs/:kmUuid/events/:eventUuid" (deleteEventA context dspConfig)

       notFound notFoundA

createDBConn dspConfig afterSuccess =
  let appConfigDatabase = dspConfig ^. dspcfgDatabaseConfig
      dbHost = appConfigDatabase ^. acdbHost
      dbPort =
        PortNumber (fromInteger (appConfigDatabase ^. acdbPort) :: PortNumber) :: PortID
      dbName = pack (appConfigDatabase ^. acdbDatabaseName)
  in withMongoDBConn dbName dbHost dbPort Nothing 10100 afterSuccess

runServer = do
  putStrLn
    "/-------------------------------------------------------------\\\n\
  \|    _____   _____ _____     _____                            |\n\
  \|   |  __ \\ / ____|  __ \\   / ____|                           |\n\
  \|   | |  | | (___ | |__) | | (___   ___ _ ____   _____ _ __   |\n\
  \|   | |  | |\\___ \\|  ___/   \\___ \\ / _ \\ '__\\ \\ / / _ \\ '__|  |\n\
  \|   | |__| |____) | |       ____) |  __/ |   \\ V /  __/ |     |   \n\
  \|   |_____/|_____/|_|      |_____/ \\___|_|    \\_/ \\___|_|     |   \n\
  \|                                                             |\n\                                             
  \\\-------------------------------------------------------------/"
  putStrLn "SERVER: started"
  eitherDspConfig <- loadDSPConfig
  case eitherDspConfig of
    Left error ->
      putStrLn
        "Can't load app-config.cfg or build-info.cfg. Maybe the file is missing or not well-formatted"
    Right dspConfig ->
      createDBConn dspConfig $ \dbPool -> do
        putStrLn "DATABASE: connected"
        let context = Context {_ctxDbPool = dbPool, _ctxConfig = Config}
        runMigration context dspConfig
        runApplication context dspConfig
