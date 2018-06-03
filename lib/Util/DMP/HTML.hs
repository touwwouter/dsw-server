module Util.DMP.HTML
       ( dmp2html
       ) where

import Data.Maybe
import Data.Monoid
import Text.Blaze.Html5 as H
import Text.Blaze.Html5.Attributes as A
import Text.Blaze.Html.Renderer.Pretty (renderHtml)

import Model.KnowledgeModel.KnowledgeModel
import Model.FilledKnowledgeModel.FilledKnowledgeModel
import Util.DMP.CSS (dmpCSS)


dmp2html :: FilledKnowledgeModel -> String
dmp2html = renderHtml . fkm2html

-- -----------------------------------------------------------------------------

textTitle = "DSW: Data Management Plan"
textFooter = "Data Managament Plan generated by Data Stewardship Wizard"
textDSW = "dsw.fairdata.solutions"
dswUrl = "https://dsw.fairdata.solutions"
textNotAnswered = "This questions has not been answered yet!"

fkm2html :: FilledKnowledgeModel -> H.Html
fkm2html km = H.docTypeHtml $ do
  H.head $ do
    H.title textTitle
    H.style . H.toHtml $ dmpCSS
  H.body $ H.article ! A.class_ "dmp" $ do
    H.header $ H.h1 $ do
      H.toHtml (textTitle <> " ")
      H.div ! A.class_ "km-name"
            ! A.id (stringValue . show . _filledKnowledgeModelUuid $ km) $
        H.toHtml (_filledKnowledgeModelName km)
    -- Section per chapter
    mapM_ chapter2html (_filledKnowledgeModelChapters km)
    H.footer $ do
      H.toHtml (textFooter <> " ")
      H.span ! A.class_ "dsw-link" $
        H.a ! A.href dswUrl
            ! A.target "_blank" $
          H.toHtml textDSW

chapter2html :: FilledChapter -> H.Html
chapter2html chapter = H.section ! A.class_ "chapter"
                                 ! A.id (stringValue . show . _filledChapterUuid $ chapter) $ do
  H.h2 ! A.class_ "title" $ H.toHtml . _filledChapterTitle $ chapter
  H.p ! A.class_ "text" $ H.toHtml . _filledChapterText $ chapter
  mapM_ question2html (_filledChapterQuestions chapter)

question2html :: FilledQuestion -> H.Html
question2html question = H.div ! A.class_ "question"
                               ! A.id (stringValue . show . _filledQuestionUuid $ question) $ do
  H.h3 ! A.class_ "title" $ H.toHtml . _filledQuestionTitle $ question
  H.p ! A.class_ "text" $ H.toHtml . _filledQuestionText $ question
  references2html . _filledQuestionReferences $ question
  experts2html .  _filledQuestionExperts $ question
  qanswer2html question

-- TODO: instead of fromJust check if is answered or not and tell something if not
qanswer2html :: FilledQuestion -> H.Html
qanswer2html question
  | notAnswered = notAnsweredHtml
  | otherwise   = case _filledQuestionQType question of
                    QuestionTypeOptions -> answerOption2html . fromJust $ optionAnswer
                    QuestionTypeList    -> answerItems2html . fromJust $ itemsAnswer
                    _                   -> answerSimple2html . fromJust $ simpleAnswer
  where
    notAnswered = isNothing optionAnswer && isNothing itemsAnswer && isNothing simpleAnswer
    optionAnswer = _filledQuestionAnswerOption question
    itemsAnswer = _filledQuestionAnswerItems question
    simpleAnswer = _filledQuestionAnswerValue question

notAnsweredHtml :: H.Html
notAnsweredHtml = H.div ! A.class_ "answer-block not-answered" $ do
  H.h4 . H.toHtml $ "Answer"
  H.p ! A.class_ "no-answer" $ H.toHtml textNotAnswered

answerSimple2html :: String -> H.Html
answerSimple2html answer = H.div ! A.class_ "answer-block answer-simple" $ do
  H.h4 . H.toHtml $ "Answer"
  H.p ! A.class_ "answer" $ H.toHtml answer

answerOption2html :: FilledAnswer -> H.Html
answerOption2html answer = H.div ! A.class_ "answer-block answer-option"
                                 ! A.id (stringValue . show . _filledAnswerUuid $ answer) $ do
  H.h4 . H.toHtml $ "Answer"
  H.div ! A.class_ "answer label" $ H.toHtml . _filledAnswerLabel $ answer
  case _filledAnswerAdvice answer of
    Just advice -> H.p ! A.class_ "advice" $ H.toHtml advice
    Nothing     -> H.toHtml ""
  H.div ! A.class_ "followups" $
    mapM_ question2html (_filledAnswerFollowUps answer)

answerItems2html :: [FilledAnswerItem] -> H.Html
answerItems2html answerItems = H.div ! A.class_ "answer-block answer-items" $ do
  H.h4 . H.toHtml $ "Answers"
  mapM_ answerItem2html answerItems

answerItem2html :: FilledAnswerItem -> H.Html
answerItem2html answerItem = H.div ! A.class_ "answer-block answer-item" $ do
  H.div ! A.class_ "answer item" $ do
    H.span ! A.class_ "title" $ H.toHtml . _filledAnswerItemTitle $ answerItem
    H.span ! A.class_ "value" $ H.toHtml . _filledAnswerItemValue $ answerItem
  H.div ! A.class_ "followups" $
    mapM_ question2html (_filledAnswerItemQuestions answerItem)

experts2html :: [Expert] -> H.Html
experts2html [] = H.toHtml ""
experts2html experts = H.div ! A.class_ "experts" $ do
  H.h4 . H.toHtml $ "Experts"
  H.ul ! A.class_ "experts-list" $
    mapM_ expert2html experts
      where expert2html expert = H.li ! A.class_ "expert"
                                      ! A.id (stringValue . show . _expertUuid $ expert) $ do
                                   H.span ! A.class_ "name" $ H.toHtml . _expertName $ expert
                                   H.toHtml " "
                                   H.span ! A.class_ "email" $ H.toHtml . _expertEmail $ expert

references2html :: [Reference] -> H.Html
references2html [] = H.toHtml ""
references2html references = H.div ! A.class_ "references" $ do
  H.h4 . H.toHtml $ "References"
  H.ul ! A.class_ "references-list" $
    mapM_ reference2html references
      where reference2html reference = H.li ! A.class_ "reference reference-dmpbook"
                                            ! A.id (stringValue . show . _referenceUuid $ reference) $
                                         H.span ! A.class_ "dmpbook-chapter" $
                                           H.toHtml . _referenceChapter $ reference
