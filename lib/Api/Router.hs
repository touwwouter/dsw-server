module Api.Router where

import Control.Lens ((^.))
import Data.Text.Lazy (Text)
import Network.HTTP.Types.Method (methodGet, methodPost, methodPut)
import Network.Wai (Middleware)
import Network.Wai.Middleware.RequestLogger
       (logStdout, logStdoutDev)
import Text.Regex
import Web.Scotty.Trans
       (ScottyT, delete, get, middleware, notFound, post, put)

import Api.Handler.ActionKey.ActionKeyHandler
import Api.Handler.Branch.BranchHandler
import Api.Handler.Common
import Api.Handler.Event.EventHandler
import Api.Handler.IO.IOHandler
import Api.Handler.Info.InfoHandler
import Api.Handler.KnowledgeModel.KnowledgeModelHandler
import Api.Handler.Migrator.MigratorHandler
import Api.Handler.Organization.OrganizationHandler
import Api.Handler.Package.PackageHandler
import Api.Handler.Questionnaire.QuestionnaireHandler
import Api.Handler.Token.TokenHandler
import Api.Handler.User.UserHandler
import Api.Handler.Version.VersionHandler
import Api.Middleware.AuthMiddleware
import Api.Middleware.CORSMiddleware
import LensesConfig
import Model.Config.DSWConfig
import Model.Context.AppContext

unauthorizedEndpoints =
  [ (methodGet, mkRegex "^$")
  , (methodPost, mkRegex "^tokens$")
  , (methodGet, mkRegex "^export/.*$")
  , (methodPost, mkRegex "^users")
  , (methodPut, mkRegex "^users/.*/state")
  , (methodPut, mkRegex "^users/.*/password")
  , (methodPut, mkRegex "^users/.*/password?hash=.*")
  , (methodPost, mkRegex "^action-keys$")
  , (methodGet, mkRegex "^questionnaires/.*/dmp")
  , (methodGet, mkRegex "^questionnaires/.*/dmp?format=.*$")
  ]

loggingM :: Environment -> Middleware
loggingM Production = logStdout
loggingM Staging = logStdoutDev
loggingM Development = logStdoutDev
loggingM Test = id

createEndpoints :: AppContext -> ScottyT Text AppContextM ()
createEndpoints context
   --------------------
   -- MIDDLEWARES
   --------------------
 = do
  middleware (loggingM (context ^. config . environment . env))
  middleware corsMiddleware
  middleware (authMiddleware (context ^. config) unauthorizedEndpoints)
   -- ------------------
   -- INFO
   -- ------------------
  get "/" getInfoA
   --------------------
   -- TOKENS
   --------------------
  post "/tokens" postTokenA
   --------------------
   -- ORGANIZATIONS
   --------------------
  get "/organizations/current" getOrganizationCurrentA
  put "/organizations/current" putOrganizationCurrentA
   --------------------
   -- USERS
   --------------------
  get "/users" getUsersA
  post "/users" postUsersA
  get "/users/current" getUserCurrentA
  get "/users/:userUuid" getUserA
  put "/users/current" putUserCurrentA
  put "/users/current/password" putUserCurrentPasswordA
  put "/users/:userUuid" putUserA
  put "/users/:userUuid/password" putUserPasswordA
  put "/users/:userUuid/state" changeUserStateA
  delete "/users/:userUuid" deleteUserA
  --  --------------------
  --  -- KNOWLEDGE MODEL
  --  --------------------
  get "/branches" getBranchesA
  post "/branches" postBranchesA
  get "/branches/:branchUuid" getBranchA
  put "/branches/:branchUuid" putBranchA
  delete "/branches/:branchUuid" deleteBranchA
  get "/branches/:branchUuid/km" getKnowledgeModelA
  get "/branches/:branchUuid/events" getEventsA
  post "/branches/:branchUuid/events/_bulk" postEventsA
  delete "/branches/:branchUuid/events" deleteEventsA
  put "/branches/:branchUuid/versions/:version" putVersionA
  get "/branches/:branchUuid/migrations/current" getMigrationsCurrentA
  post "/branches/:branchUuid/migrations/current" postMigrationsCurrentA
  delete "/branches/:branchUuid/migrations/current" deleteMigrationsCurrentA
  post "/branches/:branchUuid/migrations/current/conflict" postMigrationsCurrentConflictA
   --------------------
   -- PACKAGES
   --------------------
  get "/packages" getPackagesA
  get "/packages/unique" getUniquePackagesA
  get "/packages/:pkgId" getPackageA
  delete "/packages" deletePackagesA
  delete "/packages/:pkgId" deletePackageA
   --------------------
   -- ACTION KEYS
   --------------------
  post "/action-keys" postActionKeysA
   --------------------
   -- IMPORT/EXPORT
   --------------------
  post "/import" importA
  get "/export/:pkgId" exportA
   --------------------
   -- QUESTIONNAIRES
   --------------------
  get "/questionnaires" getQuestionnairesA
  post "/questionnaires" postQuestionnairesA
  get "/questionnaires/:qtnUuid" getQuestionnaireA
  put "/questionnaires/:qtnUuid/replies" putQuestionnaireRepliesA
  get "/questionnaires/:qtnUuid/dmp" getQuestionnaireDmpA
  delete "/questionnaires/:qtnUuid" deleteQuestionnaireA
   --------------------
   -- ERROR
   --------------------
  notFound notFoundA
