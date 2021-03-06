module Service.Migrator.Applicator.Modifiers where

import Control.Lens ((&), (.~), (^.))
import qualified Data.UUID as U

import LensesConfig
import Model.Event.Answer.AnswerEvent
import Model.Event.Chapter.ChapterEvent
import Model.Event.EventField
import Model.Event.Expert.ExpertEvent
import Model.Event.KnowledgeModel.KnowledgeModelEvent
import Model.Event.Question.QuestionEvent
import Model.Event.Reference.ReferenceEvent
import Model.KnowledgeModel.KnowledgeModel
import Model.KnowledgeModel.KnowledgeModelAccessors

applyValue (ChangedValue val) ch setter = ch & setter .~ val
applyValue NothingChanged ch setter = ch

-- -------------------------
-- KNOWLEDGE MODEL ---------
-- -------------------------
createKM :: AddKnowledgeModelEvent -> KnowledgeModel
createKM e =
  KnowledgeModel {_knowledgeModelUuid = e ^. kmUuid, _knowledgeModelName = e ^. name, _knowledgeModelChapters = []}

editKM :: EditKnowledgeModelEvent -> KnowledgeModel -> KnowledgeModel
editKM e = applyChapterIds . applyName
  where
    applyName km = applyValue (e ^. name) km name
    applyChapterIds km = applyValue (e ^. chapterIds) km kmChangeChapterIdsOrder

-- -------------------
addChapter :: KnowledgeModel -> Chapter -> KnowledgeModel
addChapter km ch = km & chapters .~ (km ^. chapters ++ [ch])

deleteChapter :: KnowledgeModel -> U.UUID -> KnowledgeModel
deleteChapter km chUuid = km & chapters .~ (filter (\ch -> ch ^. uuid /= chUuid) (km ^. chapters))

-- -------------------
-- CHAPTERS ----------
-- -------------------
createChapter :: AddChapterEvent -> Chapter
createChapter e =
  Chapter
  {_chapterUuid = e ^. chapterUuid, _chapterTitle = e ^. title, _chapterText = e ^. text, _chapterQuestions = []}

editChapter :: EditChapterEvent -> Chapter -> Chapter
editChapter e = applyQuestionIds . applyText . applyTitle
  where
    applyTitle ch = applyValue (e ^. title) ch title
    applyText ch = applyValue (e ^. text) ch text
    applyQuestionIds ch = applyValue (e ^. questionIds) ch chChangeQuestionIdsOrder

-- -------------------
addQuestion :: Chapter -> Question -> Chapter
addQuestion ch q = ch & questions .~ (ch ^. questions ++ [q])

deleteQuestion :: Chapter -> U.UUID -> Chapter
deleteQuestion ch qUuid = ch & questions .~ (filter (\q -> q ^. uuid /= qUuid) (ch ^. questions))

-- -------------------
-- QUESTIONS----------
-- -------------------
createQuestion :: AddQuestionEvent -> Maybe AnswerItemTemplate -> Maybe [Answer] -> Question
createQuestion e maybeAit maybeAnswers =
  Question
  { _questionUuid = e ^. questionUuid
  , _questionShortUuid = e ^. shortQuestionUuid
  , _questionQType = e ^. qType
  , _questionTitle = e ^. title
  , _questionText = e ^. text
  , _questionAnswerItemTemplate = maybeAit
  , _questionAnswers = maybeAnswers
  , _questionReferences = []
  , _questionExperts = []
  }

editQuestion :: EditQuestionEvent -> Question -> Question
editQuestion e =
  applyReferenceIds .
  applyExpertIds . applyAnwerIds . applyAnswerItemTemplate . applyText . applyTitle . applyType . applyShortUuid
  where
    applyShortUuid q = applyValue (e ^. shortQuestionUuid) q shortUuid
    applyType q = applyValue (e ^. qType) q qType
    applyTitle q = applyValue (e ^. title) q title
    applyText q = applyValue (e ^. text) q text
    applyAnswerItemTemplate q = applyValue (e ^. answerItemTemplatePlainWithIds) q aitAnswerItemTemplatePlainWithIds
    applyAnwerIds q = applyValue (e ^. answerIds) q qChangeAnwerIdsOrder
    applyExpertIds q = applyValue (e ^. expertIds) q qChangeExpertIdsOrder
    applyReferenceIds q = applyValue (e ^. referenceIds) q qChangeReferenceIdsOrder

-- -------------------
addAitQuestion :: Question -> Question -> Question
addAitQuestion q aitQ = q & answerItemTemplate .~ modifiedAit
  where
    modifiedAit =
      case q ^. answerItemTemplate of
        Just ait ->
          let mQuestions = (ait ^. questions) ++ [aitQ]
          in Just $ ait & questions .~ mQuestions
        Nothing -> Nothing

deleteAitQuestion :: Question -> U.UUID -> Question
deleteAitQuestion q aitQUuid = q & answerItemTemplate .~ modifiedAit
  where
    modifiedAit =
      case q ^. answerItemTemplate of
        Just ait ->
          let mQuestions = filter (\q -> q ^. uuid /= aitQUuid) (ait ^. questions)
          in Just $ ait & questions .~ mQuestions
        Nothing -> Nothing

addAnswer :: Question -> Answer -> Question
addAnswer q ans = q & answers .~ (Just modifiedAnswers)
  where
    modifiedAnswers =
      case q ^. answers of
        Just as -> as ++ [ans]
        Nothing -> [ans]

deleteAnswer :: Question -> U.UUID -> Question
deleteAnswer q ansUuid = q & answers .~ modifiedAnswers
  where
    modifiedAnswers =
      case q ^. answers of
        Just as -> Just (filter (\ans -> ans ^. uuid /= ansUuid) as)
        Nothing -> Nothing

addExpert :: Question -> Expert -> Question
addExpert q exp = q & experts .~ (q ^. experts ++ [exp])

deleteExpert :: Question -> U.UUID -> Question
deleteExpert q expUuid = q & experts .~ (filter (\exp -> exp ^. uuid /= expUuid) (q ^. experts))

addReference :: Question -> Reference -> Question
addReference q ref = q & references .~ (q ^. references ++ [ref])

deleteReference :: Question -> U.UUID -> Question
deleteReference q refUuid = q & references .~ (filter (\ref -> ref ^. uuid /= refUuid) (q ^. references))

-- -------------------
-- ANSWER ------------
-- -------------------
createAnswer :: AddAnswerEvent -> Answer
createAnswer e =
  Answer {_answerUuid = e ^. answerUuid, _answerLabel = e ^. label, _answerAdvice = e ^. advice, _answerFollowUps = []}

editAnswer :: EditAnswerEvent -> Answer -> Answer
editAnswer e = applyFollowUps . applyAdvice . applyLabel
  where
    applyLabel ans = applyValue (e ^. label) ans label
    applyAdvice ans = applyValue (e ^. advice) ans advice
    applyFollowUps ans = applyValue (e ^. followUpIds) ans ansChangeFollowUpIdsOrder

-- -------------------
addFuQuestion :: Answer -> Question -> Answer
addFuQuestion ans q = ans & followUps .~ (ans ^. followUps ++ [q])

deleteFuQuestion :: Answer -> U.UUID -> Answer
deleteFuQuestion ans qUuid = ans & followUps .~ (filter (\q -> q ^. uuid /= qUuid) (ans ^. followUps))

-- -------------------
-- EXPERT ------------
-- -------------------
createExpert :: AddExpertEvent -> Expert
createExpert e = Expert {_expertUuid = e ^. expertUuid, _expertName = e ^. name, _expertEmail = e ^. email}

editExpert :: EditExpertEvent -> Expert -> Expert
editExpert e = applyEmail . applyName
  where
    applyName exp = applyValue (e ^. name) exp name
    applyEmail exp = applyValue (e ^. email) exp email

-- -------------------
-- REFERENCE ---------
-- -------------------
createReference :: AddReferenceEvent -> Reference
createReference e = Reference {_referenceUuid = e ^. referenceUuid, _referenceChapter = e ^. chapter}

editReference :: EditReferenceEvent -> Reference -> Reference
editReference e = applyChapter
  where
    applyChapter ref = applyValue (e ^. chapter) ref chapter
