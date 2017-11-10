module Database.BSON.KnowledgeModelContainer.KnowledgeModelContainerWithKM where

import Control.Lens ((^.))
import qualified Data.Bson as BSON
import Data.Bson.Generic
import Data.Maybe
import Data.UUID
import GHC.Generics

import Database.BSON.Common
import Database.BSON.KnowledgeModel.KnowledgeModel
import Model.KnowledgeModelContainer.KnowledgeModelContainer

instance FromBSON KnowledgeModelContainerWithKM where
  fromBSON doc = do
    uuid <- deserializeUUID $ BSON.lookup "uuid" doc
    name <- BSON.lookup "name" doc
    shortName <- BSON.lookup "shortName" doc
    parentPackageName <- BSON.lookup "parentPackageName" doc
    parentPackageVersion <- BSON.lookup "parentPackageVersion" doc
    kmSerialized <- BSON.lookup "knowledgeModel" doc
    km <- fromBSON kmSerialized
    return
      KnowledgeModelContainerWithKM
      { _kmcwkmKmContainerUuid = uuid
      , _kmcwkmName = name
      , _kmcwkmShortName = shortName
      , _kmcwkmParentPackageName = parentPackageName
      , _kmcwkmParentPackageVersion = parentPackageVersion
      , _kmcwkmKM = km
      }