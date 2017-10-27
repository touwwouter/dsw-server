module Specs.ApplicatorSpec where

import Control.Lens
import Data.Maybe
import Test.Hspec

import Fixtures.Event.Events
import Fixtures.KnowledgeModel.AnswersAndFollowUpQuestions
import Fixtures.KnowledgeModel.Chapters
import Fixtures.KnowledgeModel.Experts
import Fixtures.KnowledgeModel.KnowledgeModels
import Fixtures.KnowledgeModel.Questions
import Fixtures.KnowledgeModel.References
import KMMigration.Migration.Event.Chapter.AddChapterEvent
import KMMigration.Migration.Event.Common
import KMMigration.Migration.Event.EventApplicable
import KMMigration.Migration.Event.KnowledgeModel.EditKnowledgeModelEvent
import KMMigration.Migration.Migration
import KMMigration.Model.Event
import KMMigration.Model.KnowledgeModel

applicatorSpec =
  describe "Applicator" $ do
    describe "Apply: No events" $
      it "Apply: No events" $ do
        let emptyEvents = []
        let computed = migrate km1 emptyEvents
        let expected = km1
        computed `shouldBe` expected
    -- ---------------
    describe "Apply:  KM Events" $ do
      it "Apply:  AddKnowledgeEvent" $ do
        let computed = migrate undefined [MkEventApplicable a_km1]
        let expected = km1WithoutChapters
        computed `shouldBe` expected
      it "Apply:  EditKnowledgeEvent" $ do
        let computed = migrate km1 [MkEventApplicable e_km1]
        let expected = km1WithChangeProperties
        computed `shouldBe` expected
    -- ---------------
    describe "Apply:  Chapter Events" $ do
      it "Apply:  AddChapterEvent" $ do
        let computed = migrate km1 [MkEventApplicable a_km1_ch3]
        let expected =
              km1 & kmChapters .~ [chapter1, chapter2, chapter3WithoutQuestions]
        computed `shouldBe` expected
      it "Apply:  EditChapterEvent" $ do
        let computed = migrate km1 [MkEventApplicable e_km1_ch1]
        let expected =
              km1 & kmChapters .~ [chapter1WithChangeProperties, chapter2]
        computed `shouldBe` expected
      it "Apply:  DeleteChapterEvent" $ do
        let computed = migrate km1 [MkEventApplicable d_km1_ch1]
        let expected = km1 & kmChapters .~ [chapter2]
        computed `shouldBe` expected
    -- ---------------
    describe "Apply:  Question Events" $ do
      it "Apply:  AddQuestionEvent" $ do
        let computed = migrate km1 [MkEventApplicable a_km1_ch1_q3]
        let expected =
              km1 & kmChapters .~ [chapter1WithAddedQuestion3, chapter2]
        computed `shouldBe` expected
      it "Apply:  EditQuestionEvent" $ do
        let computed = migrate km1 [MkEventApplicable e_km1_ch1_q2]
        let expected =
              km1 & kmChapters .~ [chapter1WithChangedQuestion2, chapter2]
        computed `shouldBe` expected
      it "Apply:  DeleteQuestionEvent" $ do
        let initKM = km1 & kmChapters .~ [chapter1WithAddedQuestion3, chapter2]
        let computed = migrate initKM [MkEventApplicable d_km1_ch1_q3]
        let expected = km1
        computed `shouldBe` expected
    -- ---------------
    describe "Apply:  Answer Events" $ do
      it "Apply:  AddAnswerEvent" $ do
        let computed = migrate km1 [MkEventApplicable a_km1_ch1_q2_aMaybe]
        let question2WithAddedAnswer =
              question2 & qAnswers .~ [answerNo1, answerYes1, answerMaybe]
        let chapter1WithAddedAnswer =
              chapter1 & chQuestions .~ [question1, question2WithAddedAnswer]
        let expected = km1 & kmChapters .~ [chapter1WithAddedAnswer, chapter2]
        computed `shouldBe` expected
      it "Apply:  EditAnswerEvent" $ do
        let computed = migrate km1 [MkEventApplicable e_km1_ch1_q2_aYes1]
        let question2WithChangedAnswer =
              question2 & qAnswers .~ [answerNo1, answerYes1Changed]
        let chapter1WithChangedAnswer =
              chapter1 & chQuestions .~ [question1, question2WithChangedAnswer]
        let expected = km1 & kmChapters .~ [chapter1WithChangedAnswer, chapter2]
        computed `shouldBe` expected
      it "Apply:  DeleteAnswerEvent" $ do
        let computed = migrate km1 [MkEventApplicable d_km1_ch1_q2_aYes1]
        let question2WithDeletedAnswer = question2 & qAnswers .~ [answerNo1]
        let chapter1WithDeletedAnswer =
              chapter1 & chQuestions .~ [question1, question2WithDeletedAnswer]
        let expected = km1 & kmChapters .~ [chapter1WithDeletedAnswer, chapter2]
        computed `shouldBe` expected
    -- ---------------
    describe "Apply:  Follow-Up Question Events" $ do
      it "Apply:  AddFollowUpQuestionEvent" $ do
        let event = a_km1_ch1_ansYes1_fuq1_ansYes3_fuq2_ansYes4_fuq3
        let computed = migrate km1 [MkEventApplicable event]
        let expFUQ3 = followUpQuestion3
        let expAnswerYes4 = answerYes4 & ansFollowing .~ [expFUQ3]
        let expFUQ2 = followUpQuestion2 & qAnswers .~ [answerNo4, expAnswerYes4]
        let expAnswerYes3 = answerYes3 & ansFollowing .~ [expFUQ2]
        let expFUQ1 = followUpQuestion1 & qAnswers .~ [answerNo3, expAnswerYes3]
        let expAnswerYes1 = answerYes1 & ansFollowing .~ [expFUQ1]
        let expQuestion2 = question2 & qAnswers .~ [answerNo1, expAnswerYes1]
        let expChapter1 = chapter1 & chQuestions .~ [question1, expQuestion2]
        let expected = km1 & kmChapters .~ [expChapter1, chapter2]
        computed `shouldBe` expected
      it "Apply:  EditFollowUpQuestionEvent" $ do
        let event = e_km1_ch1_ansYes1_fuq1_ansYes3_fuq2
        let computed = migrate km1 [MkEventApplicable event]
        let expFUQ2 = followUpQuestion2Changed
        let expAnswerYes3 = answerYes3 & ansFollowing .~ [expFUQ2]
        let expFUQ1 = followUpQuestion1 & qAnswers .~ [answerNo3, expAnswerYes3]
        let expAnswerYes1 = answerYes1 & ansFollowing .~ [expFUQ1]
        let expQuestion2 = question2 & qAnswers .~ [answerNo1, expAnswerYes1]
        let expChapter1 = chapter1 & chQuestions .~ [question1, expQuestion2]
        let expected = km1 & kmChapters .~ [expChapter1, chapter2]
        computed `shouldBe` expected
      it "Apply:  DeleteFollowUpQuestionEvent" $ do
        let event = d_km1_ch1_ansYes1_fuq1_ansYes3_fuq2
        let computed = migrate km1 [MkEventApplicable event]
        let expAnswerYes3 = answerYes3 & ansFollowing .~ []
        let expFUQ1 = followUpQuestion1 & qAnswers .~ [answerNo3, expAnswerYes3]
        let expAnswerYes1 = answerYes1 & ansFollowing .~ [expFUQ1]
        let expQuestion2 = question2 & qAnswers .~ [answerNo1, expAnswerYes1]
        let expChapter1 = chapter1 & chQuestions .~ [question1, expQuestion2]
        let expected = km1 & kmChapters .~ [expChapter1, chapter2]
        computed `shouldBe` expected
    -- ---------------
    describe "Apply:  Expert Events" $ do
      it "Apply:  AddExpertEvent" $ do
        let computed = migrate km1 [MkEventApplicable a_km1_ch1_q2_eJohn]
        let question2WithAddedExpert =
              question2 & qExperts .~ [expertDarth, expertLuke, expertJohn]
        let chapter1WithAddedExpert =
              chapter1 & chQuestions .~ [question1, question2WithAddedExpert]
        let expected = km1 & kmChapters .~ [chapter1WithAddedExpert, chapter2]
        computed `shouldBe` expected
      it "Apply:  EditExpertEvent" $ do
        let computed = migrate km1 [MkEventApplicable e_km1_ch1_q2_eDarth]
        let question2WithChangedExpert =
              question2 & qExperts .~ [expertDarthChanged, expertLuke]
        let chapter1WithChangedExpert =
              chapter1 & chQuestions .~ [question1, question2WithChangedExpert]
        let expected = km1 & kmChapters .~ [chapter1WithChangedExpert, chapter2]
        computed `shouldBe` expected
      it "Apply:  DeleteExpertEvent" $ do
        let computed = migrate km1 [MkEventApplicable d_km1_ch1_q2_eLuke]
        let question2WithDeletedExpert = question2 & qExperts .~ [expertDarth]
        let chapter1WithDeletedExpert =
              chapter1 & chQuestions .~ [question1, question2WithDeletedExpert]
        let expected = km1 & kmChapters .~ [chapter1WithDeletedExpert, chapter2]
        computed `shouldBe` expected
  -- ---------------
    describe "Apply:  Reference Events" $ do
      it "Apply:  AddReferenceEvent" $ do
        let computed = migrate km1 [MkEventApplicable a_km1_ch1_q2_rCh3]
        let question2WithAddedReference =
              question2 & qReferences .~
              [referenceCh1, referenceCh2, referenceCh3]
        let chapter1WithAddedReference =
              chapter1 & chQuestions .~ [question1, question2WithAddedReference]
        let expected =
              km1 & kmChapters .~ [chapter1WithAddedReference, chapter2]
        computed `shouldBe` expected
      it "Apply:  EditReferenceEvent" $ do
        let computed = migrate km1 [MkEventApplicable e_km1_ch1_q2_rCh1]
        let question2WithChangedReference =
              question2 & qReferences .~ [referenceCh1Changed, referenceCh2]
        let chapter1WithChangedReference =
              chapter1 & chQuestions .~
              [question1, question2WithChangedReference]
        let expected =
              km1 & kmChapters .~ [chapter1WithChangedReference, chapter2]
        computed `shouldBe` expected
      it "Apply:  DeleteReferenceEvent" $ do
        let computed = migrate km1 [MkEventApplicable d_km1_ch1_q2_rCh2]
        let question2WithDeletedReference =
              question2 & qReferences .~ [referenceCh1]
        let chapter1WithDeletedReference =
              chapter1 & chQuestions .~
              [question1, question2WithDeletedReference]
        let expected =
              km1 & kmChapters .~ [chapter1WithDeletedReference, chapter2]
        computed `shouldBe` expected