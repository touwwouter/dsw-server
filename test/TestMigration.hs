module TestMigration where

import Database.DAO.ActionKey.ActionKeyDAO
import Database.DAO.Branch.BranchDAO
import Database.DAO.Migrator.MigratorDAO
import Database.DAO.Organization.OrganizationDAO
import Database.DAO.User.UserDAO
import Database.Migration.Organization.Data.Organizations
import Database.Migration.User.Data.Users

import Specs.Common

resetDB appContext = do
  runInContext (deleteUsers) appContext
  runInContext (insertUser userAlbert) appContext
  runInContext (deleteOrganizations) appContext
  runInContext (insertOrganization org1) appContext
  runInContext (deleteBranches) appContext
  runInContext (deleteMigratorStates) appContext
  runInContext (deleteActionKeys) appContext
