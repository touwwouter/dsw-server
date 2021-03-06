module Service.User.UserValidation where

import Data.Either (isRight)

import Common.Error
import Common.Localization
import Common.Types
import Database.DAO.User.UserDAO
import Model.Context.AppContext

validateUserEmailUniqueness :: Email -> AppContextM (Maybe AppError)
validateUserEmailUniqueness email = do
  eitherUserFromDb <- findUserByEmail email
  if isRight eitherUserFromDb
    then return . Just . createErrorWithFieldError $ ("email", _ERROR_VALIDATION__USER_EMAIL_UNIQUENESS email)
    else return Nothing

validateUserChangedEmailUniqueness :: Email -> Email -> AppContextM (Maybe AppError)
validateUserChangedEmailUniqueness newEmail oldEmail =
  if newEmail /= oldEmail
    then validateUserEmailUniqueness newEmail
    else return Nothing

-- --------------------------------
-- HELPERS
-- --------------------------------
heValidateUserEmailUniqueness email callback = do
  maybeError <- validateUserEmailUniqueness email
  case maybeError of
    Nothing -> callback
    Just error -> return . Left $ error

heValidateUserChangedEmailUniqueness newEmail oldEmail callback = do
  maybeError <- validateUserChangedEmailUniqueness newEmail oldEmail
  case maybeError of
    Nothing -> callback
    Just error -> return . Left $ error
