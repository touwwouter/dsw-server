module Database.Migration.Branch.Data.KnowledgeModel.References where

import Control.Lens
import Data.Maybe
import qualified Data.UUID as U

import LensesConfig
import Model.KnowledgeModel.KnowledgeModel

referenceCh1 :: Reference
referenceCh1 =
  Reference
  {_referenceUuid = fromJust $ U.fromString "a401b481-51b6-49ac-afca-ea957740e7ba", _referenceChapter = "chapter1"}

referenceCh1Changed :: Reference
referenceCh1Changed = Reference {_referenceUuid = referenceCh1 ^. uuid, _referenceChapter = "EDITED: chapter1"}

referenceCh2 :: Reference
referenceCh2 =
  Reference
  {_referenceUuid = fromJust $ U.fromString "5004803d-43f6-4932-ab04-5a7e608894a5", _referenceChapter = "chapter2"}

referenceCh3 :: Reference
referenceCh3 =
  Reference
  {_referenceUuid = fromJust $ U.fromString "14255506-6c88-438d-a1ad-eea2071ee9cb", _referenceChapter = "chapter3"}
