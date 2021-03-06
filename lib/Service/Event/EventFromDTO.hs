module Service.Event.EventFromDTO where

import Control.Lens ((^.))

import Api.Resource.Event.EventDTO
import Api.Resource.Event.EventFieldDTO
import Api.Resource.Event.EventPathDTO
import Api.Resource.KnowledgeModel.KnowledgeModelDTO
import LensesConfig
import Model.Event.Answer.AnswerEvent
import Model.Event.Chapter.ChapterEvent
import Model.Event.Event
import Model.Event.EventField
import Model.Event.EventPath
import Model.Event.Expert.ExpertEvent
import Model.Event.KnowledgeModel.KnowledgeModelEvent
import Model.Event.Question.QuestionEvent
import Model.Event.Reference.ReferenceEvent
import Model.KnowledgeModel.KnowledgeModel
import Service.KnowledgeModel.KnowledgeModelMapper

-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
class EventFromDTO a where
  fromDTO :: a -> Event

fromEventFieldDTO :: EventFieldDTO a -> EventField a
fromEventFieldDTO (ChangedValueDTO value) = ChangedValue value
fromEventFieldDTO NothingChangedDTO = NothingChanged

fromEventPathItemDTO :: EventPathItemDTO -> EventPathItem
fromEventPathItemDTO dto = EventPathItem {_eventPathItemPType = dto ^. pType, _eventPathItemUuid = dto ^. uuid}

fromEventPathDTO :: EventPathDTO -> EventPath
fromEventPathDTO dto = fromEventPathItemDTO <$> dto

fromEventFieldAndAnswerItemTemplate ::
     EventFieldDTO (Maybe AnswerItemTemplateDTO) -> EventField (Maybe AnswerItemTemplate)
fromEventFieldAndAnswerItemTemplate efMaybeAitDto =
  case efMaybeAitDto of
    ChangedValueDTO maybeAitDto -> ChangedValue $ fromAnswerItemTemplateDTO <$> maybeAitDto
    NothingChangedDTO -> NothingChanged

fromEventFieldAndAnswerItemTemplatePlain ::
     EventFieldDTO (Maybe AnswerItemTemplatePlainDTO) -> EventField (Maybe AnswerItemTemplatePlain)
fromEventFieldAndAnswerItemTemplatePlain efMaybeAitDto =
  case efMaybeAitDto of
    ChangedValueDTO maybeAitDto -> ChangedValue $ fromAnswerItemTemplatePlainDTO <$> maybeAitDto
    NothingChangedDTO -> NothingChanged

fromEventFieldAndAnswerItemTemplatePlainWithIds ::
     EventFieldDTO (Maybe AnswerItemTemplatePlainWithIdsDTO) -> EventField (Maybe AnswerItemTemplatePlainWithIds)
fromEventFieldAndAnswerItemTemplatePlainWithIds efMaybeAitDto =
  case efMaybeAitDto of
    ChangedValueDTO maybeAitDto -> ChangedValue $ fromAnswerItemTemplatePlainWithIdsDTO <$> maybeAitDto
    NothingChangedDTO -> NothingChanged

-- -------------------------
-- Knowledge Model ---------
-- -------------------------
instance EventFromDTO AddKnowledgeModelEventDTO where
  fromDTO dto =
    AddKnowledgeModelEvent'
      AddKnowledgeModelEvent
      { _addKnowledgeModelEventUuid = dto ^. uuid
      , _addKnowledgeModelEventPath = fromEventPathDTO $ dto ^. path
      , _addKnowledgeModelEventKmUuid = dto ^. kmUuid
      , _addKnowledgeModelEventName = dto ^. name
      }

instance EventFromDTO EditKnowledgeModelEventDTO where
  fromDTO dto =
    EditKnowledgeModelEvent'
      EditKnowledgeModelEvent
      { _editKnowledgeModelEventUuid = dto ^. uuid
      , _editKnowledgeModelEventPath = fromEventPathDTO $ dto ^. path
      , _editKnowledgeModelEventKmUuid = dto ^. kmUuid
      , _editKnowledgeModelEventName = fromEventFieldDTO $ dto ^. name
      , _editKnowledgeModelEventChapterIds = fromEventFieldDTO $ dto ^. chapterIds
      }

-- -------------------------
-- Chapter -----------------
-- -------------------------
instance EventFromDTO AddChapterEventDTO where
  fromDTO dto =
    AddChapterEvent'
      AddChapterEvent
      { _addChapterEventUuid = dto ^. uuid
      , _addChapterEventPath = fromEventPathDTO $ dto ^. path
      , _addChapterEventChapterUuid = dto ^. chapterUuid
      , _addChapterEventTitle = dto ^. title
      , _addChapterEventText = dto ^. text
      }

instance EventFromDTO EditChapterEventDTO where
  fromDTO dto =
    EditChapterEvent'
      EditChapterEvent
      { _editChapterEventUuid = dto ^. uuid
      , _editChapterEventPath = fromEventPathDTO $ dto ^. path
      , _editChapterEventChapterUuid = dto ^. chapterUuid
      , _editChapterEventTitle = fromEventFieldDTO $ dto ^. title
      , _editChapterEventText = fromEventFieldDTO $ dto ^. text
      , _editChapterEventQuestionIds = fromEventFieldDTO $ dto ^. questionIds
      }

instance EventFromDTO DeleteChapterEventDTO where
  fromDTO dto =
    DeleteChapterEvent'
      DeleteChapterEvent
      { _deleteChapterEventUuid = dto ^. uuid
      , _deleteChapterEventPath = fromEventPathDTO $ dto ^. path
      , _deleteChapterEventChapterUuid = dto ^. chapterUuid
      }

-- -------------------------
-- Question ----------------
-- -------------------------
instance EventFromDTO AddQuestionEventDTO where
  fromDTO dto =
    AddQuestionEvent'
      AddQuestionEvent
      { _addQuestionEventUuid = dto ^. uuid
      , _addQuestionEventPath = fromEventPathDTO $ dto ^. path
      , _addQuestionEventQuestionUuid = dto ^. questionUuid
      , _addQuestionEventShortQuestionUuid = dto ^. shortQuestionUuid
      , _addQuestionEventQType = dto ^. qType
      , _addQuestionEventTitle = dto ^. title
      , _addQuestionEventText = dto ^. text
      , _addQuestionEventAnswerItemTemplatePlain = fromAnswerItemTemplatePlainDTO <$> dto ^. answerItemTemplatePlain
      }

instance EventFromDTO EditQuestionEventDTO where
  fromDTO dto =
    EditQuestionEvent'
      EditQuestionEvent
      { _editQuestionEventUuid = dto ^. uuid
      , _editQuestionEventPath = fromEventPathDTO $ dto ^. path
      , _editQuestionEventQuestionUuid = dto ^. questionUuid
      , _editQuestionEventShortQuestionUuid = fromEventFieldDTO $ dto ^. shortQuestionUuid
      , _editQuestionEventQType = fromEventFieldDTO $ dto ^. qType
      , _editQuestionEventTitle = fromEventFieldDTO $ dto ^. title
      , _editQuestionEventText = fromEventFieldDTO $ dto ^. text
      , _editQuestionEventAnswerItemTemplatePlainWithIds =
          fromEventFieldAndAnswerItemTemplatePlainWithIds $ dto ^. answerItemTemplatePlainWithIds
      , _editQuestionEventAnswerIds = fromEventFieldDTO $ dto ^. answerIds
      , _editQuestionEventExpertIds = fromEventFieldDTO $ dto ^. expertIds
      , _editQuestionEventReferenceIds = fromEventFieldDTO $ dto ^. referenceIds
      }

instance EventFromDTO DeleteQuestionEventDTO where
  fromDTO dto =
    DeleteQuestionEvent'
      DeleteQuestionEvent
      { _deleteQuestionEventUuid = dto ^. uuid
      , _deleteQuestionEventPath = fromEventPathDTO $ dto ^. path
      , _deleteQuestionEventQuestionUuid = dto ^. questionUuid
      }

-- -------------------------
-- Answer ------------------
-- -------------------------
instance EventFromDTO AddAnswerEventDTO where
  fromDTO dto =
    AddAnswerEvent'
      AddAnswerEvent
      { _addAnswerEventUuid = dto ^. uuid
      , _addAnswerEventPath = fromEventPathDTO $ dto ^. path
      , _addAnswerEventAnswerUuid = dto ^. answerUuid
      , _addAnswerEventLabel = dto ^. label
      , _addAnswerEventAdvice = dto ^. advice
      }

instance EventFromDTO EditAnswerEventDTO where
  fromDTO dto =
    EditAnswerEvent'
      EditAnswerEvent
      { _editAnswerEventUuid = dto ^. uuid
      , _editAnswerEventPath = fromEventPathDTO $ dto ^. path
      , _editAnswerEventAnswerUuid = dto ^. answerUuid
      , _editAnswerEventLabel = fromEventFieldDTO $ dto ^. label
      , _editAnswerEventAdvice = fromEventFieldDTO $ dto ^. advice
      , _editAnswerEventFollowUpIds = fromEventFieldDTO $ dto ^. followUpIds
      }

instance EventFromDTO DeleteAnswerEventDTO where
  fromDTO dto =
    DeleteAnswerEvent'
      DeleteAnswerEvent
      { _deleteAnswerEventUuid = dto ^. uuid
      , _deleteAnswerEventPath = fromEventPathDTO $ dto ^. path
      , _deleteAnswerEventAnswerUuid = dto ^. answerUuid
      }

-- -------------------------
-- Expert ------------------
-- -------------------------
instance EventFromDTO AddExpertEventDTO where
  fromDTO dto =
    AddExpertEvent'
      AddExpertEvent
      { _addExpertEventUuid = dto ^. uuid
      , _addExpertEventPath = fromEventPathDTO $ dto ^. path
      , _addExpertEventExpertUuid = dto ^. expertUuid
      , _addExpertEventName = dto ^. name
      , _addExpertEventEmail = dto ^. email
      }

instance EventFromDTO EditExpertEventDTO where
  fromDTO dto =
    EditExpertEvent'
      EditExpertEvent
      { _editExpertEventUuid = dto ^. uuid
      , _editExpertEventPath = fromEventPathDTO $ dto ^. path
      , _editExpertEventExpertUuid = dto ^. expertUuid
      , _editExpertEventName = fromEventFieldDTO $ dto ^. name
      , _editExpertEventEmail = fromEventFieldDTO $ dto ^. email
      }

instance EventFromDTO DeleteExpertEventDTO where
  fromDTO dto =
    DeleteExpertEvent'
      DeleteExpertEvent
      { _deleteExpertEventUuid = dto ^. uuid
      , _deleteExpertEventPath = fromEventPathDTO $ dto ^. path
      , _deleteExpertEventExpertUuid = dto ^. expertUuid
      }

-- -------------------------
-- Reference ---------------
-- -------------------------
instance EventFromDTO AddReferenceEventDTO where
  fromDTO dto =
    AddReferenceEvent'
      AddReferenceEvent
      { _addReferenceEventUuid = dto ^. uuid
      , _addReferenceEventPath = fromEventPathDTO $ dto ^. path
      , _addReferenceEventReferenceUuid = dto ^. referenceUuid
      , _addReferenceEventChapter = dto ^. chapter
      }

instance EventFromDTO EditReferenceEventDTO where
  fromDTO dto =
    EditReferenceEvent'
      EditReferenceEvent
      { _editReferenceEventUuid = dto ^. uuid
      , _editReferenceEventPath = fromEventPathDTO $ dto ^. path
      , _editReferenceEventReferenceUuid = dto ^. referenceUuid
      , _editReferenceEventChapter = fromEventFieldDTO $ dto ^. chapter
      }

instance EventFromDTO DeleteReferenceEventDTO where
  fromDTO dto =
    DeleteReferenceEvent'
      DeleteReferenceEvent
      { _deleteReferenceEventUuid = dto ^. uuid
      , _deleteReferenceEventPath = fromEventPathDTO $ dto ^. path
      , _deleteReferenceEventReferenceUuid = dto ^. referenceUuid
      }
