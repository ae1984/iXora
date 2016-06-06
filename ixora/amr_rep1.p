/* amr_rep1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Амортизационный отчисления, расходы на ремонт и другие вычеты по фиксированным активам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        amr_rech
 * MENU
        6.1.5.3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        10.12.2003 suchkov - исправлены ошибки в расчетах
        04.03.2004 suchkov - добавлено - Дата ввода, N Группы, N Подруппы, Норма амортизации
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

DEFINE NEW SHARED TEMP-TABLE ttblAm
  FIELD anum as integer format '99'
  FIELD catname like taxcat.name
  FIELD cat     like taxcat.type format '99'
  FIELD subcat  like taxcat.cat  format '99'
  FIELD amPrec  like taxcat.pc   format '99'
  FIELD amBBal  like ast.amt[4] format 'zzz,zzz,zzz.99'
  FIELD amIn      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amOut     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amRepair  like ast.amt[4] format 'zzz,zzz,zzz.99-'

  FIELD amTemp      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempPrec  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempR     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempRInc  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD am100MRP     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempF     like ast.amt[4] format 'zzz,zzz,zzz.99-'
. 

DEFINE NEW SHARED TEMP-TABLE ttblAm2
  FIELD anum as integer format '99'
  FIELD catname like taxcat.name
  FIELD cat     like taxcat.type format '99'
  FIELD subcat  like taxcat.cat  format '99'
  FIELD amPrec  like taxcat.pc   format '99'
  FIELD amBBal  like ast.amt[4] format 'zzz,zzz,zzz.99'
  FIELD amIn      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amOut     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amRepair  like ast.amt[4] format 'zzz,zzz,zzz.99-'

  FIELD amTemp      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempPrec  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempR     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempRInc  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD am100MRP     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempF     like ast.amt[4] format 'zzz,zzz,zzz.99-'
. 


DEFINE NEW SHARED TEMP-TABLE tblFull
  FIELD fAst     like ast.ast
  FIELD fName    like ast.name
  FIELD fBAmt    like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fIn      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fOut     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fRepair  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fCode    as char
  FIELD fCat     like taxcat.type format '99'
  FIELD fSubCat  like taxcat.cat  format '99'
  FIELD fPrec    like taxcat.pc   format '99'
  FIELD fAmr2    as logical 
  FIELD fAcc     as char format 'x(10)' 
  FIELD fRdt     as date
  INDEX fInx     fAst fCode ASCENDING
.

DEFINE NEW SHARED VARIABLE bDate AS DATE init 01/01/02. 
DEFINE NEW SHARED VARIABLE eDate AS DATE init TODAY.

DEFINE VARIABLE astFrom AS CHAR.  /* Баланс на начало года с этих карточек */
DEFINE VARIABLE astTo AS CHAR.    /* Копируется в эти */
DEFINE VARIABLE astfCode AS CHAR.    /* мфо куда копировать */


DEFINE VARIABLE aTemp      AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE aTempPrec  AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE aTemp15    AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE aTempR     AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE aTempRInc  AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE aTempF     AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE aRepSum    AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE a40MRP     AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE TempSum    AS decimal format 'zzz,zzz,zzz.99-'.
DEFINE VARIABLE report-type AS integer.


DEFINE BUTTON arep1 LABEL     " Фиксированные активы  ".
DEFINE BUTTON arep2 LABEL     " Нематериальные активы ".
DEFINE BUTTON arep3 LABEL     " Двойная амортизация   ".
DEFINE BUTTON afullrep LABEL  " Полный отчет          ".
DEFINE BUTTON afullrep2 LABEL " Полный отчет дв. аморт".
DEFINE BUTTON aexit LABEL     " Выход                 ". 

DEFINE BUFFER bTbl FOR tblFull.

DEFINE FRAME af1
         skip
         arep1 skip
         arep2 skip 
         arep3 skip
         afullrep skip
         afullrep2 skip
         aexit   skip WITH CENTERED ROW 6.

SESSION:NUMERIC-FORMAT = 'European'.

bDate = date("01/01/" + string(year(today))) .

UPDATE "Начало периода: " bDate no-label skip 
       "Конец периода : " eDate no-label.

ON CHOOSE OF arep1, arep2, arep3, afullrep, afullrep2 do:



  if self:label = "Фиксированные активы" then report-type = 1.
  else           
  if self:label = "Нематериальные активы" then report-type = 2.
  else 
  if self:label = "Двойная амортизация" then report-type = 3.
  else 
  if self:label = "Полный отчет" then report-type = 4.
  else 
  if self:label = "Полный отчет дв. аморт" then report-type = 5.



  CASE report-type:

  WHEN 1 THEN
  DO: 
      output to 'ast.csv'.
      for each ttblAm where cat <> 19 or subcat <> 1:
        put anum ';' catname ';' cat ';' subcat ';' amPrec ';' amPrec ';' amBBal ';' amIn ';' amOut ';'
            amTemp ';'  amTempPrec ';' amTempR ';' amTempRInc ';' am100MRP ';' ';' amTempF skip.  
        accumulate amBBal     (TOTAL).
        accumulate amIn       (TOTAL).
        accumulate amOut      (TOTAL).
        accumulate amTemp     (TOTAL).
        accumulate amTempPrec (TOTAL).
        accumulate amTempR    (TOTAL).
        accumulate amTempRInc (TOTAL).   
        accumulate am100MRP   (TOTAL).   
        accumulate amTempF    (TOTAL).   
    end.
    
    put unformatted ';' ';' ';' ';' ';' ';'
        (accum TOTAL amBBal)       ';'
        (accum TOTAL amIn)         ';'
        (accum TOTAL amOut)        ';'
        (accum TOTAL amTemp)       ';'
        (accum TOTAL amTempPrec)   ';'
        (accum TOTAL amTempR)      ';'
        (accum TOTAL amTempRInc)   ';' 
        (accum TOTAL am100MRP)     ';' ';'
        (accum TOTAL amTempF)      
        skip.
    
    output close.
  
    run menu-prt('ast.csv').
    unix silent rm ast.csv.
  END.

  WHEN 2 THEN
  DO: 
    output to 'ast1.csv'.
  
    for each ttblAm where cat = 19 and subcat = 1:
        put ' 1' ';' catname ';' amPrec ';' amPrec ';' amBBal ';' amIn ';' amOut ';' 
                     amTemp ';'  amTempPrec ';' am100MRP ';' ';' amTempF skip. 
        accumulate amBBal     (TOTAL).
        accumulate amIn       (TOTAL).
        accumulate amOut      (TOTAL).
        accumulate amTemp     (TOTAL).
        accumulate amTempPrec (TOTAL).
        accumulate am100MRP   (TOTAL).
        accumulate amTempF    (TOTAL).   
    end.

    put unformatted ';' ';' ';' ';'
        (accum TOTAL amBBal)       ';'
        (accum TOTAL amIn)         ';'
        (accum TOTAL amOut)        ';'
        (accum TOTAL amTemp)       ';'
        (accum TOTAL amTempPrec)   ';' 
        (accum TOTAL am100MRP)     ';' ';'
        (accum TOTAL amTempF)       
        skip.

    output close.

    run menu-prt('ast1.csv').
    unix silent rm ast1.csv.
  END.

  WHEN 3 THEN
  DO: 
      output to 'ast2.csv'.
      for each ttblAm2:
        put ttblAm2.anum ';' ttblAm2.catname ';' ttblAm2.cat ';' ttblAm2.subcat ';' ttblAm2.amPrec ';' ttblAm2.amPrec ';' 
            ttblAm2.amBBal ';' ttblAm2.amIn ';' ttblAm2.amOut ';'
            ttblAm2.amTemp ';' ttblAm2.amTempPrec ';' ttblAm2.amTempR ';' ttblAm2.amTempRInc ';' ttblAm2.am100MRP ';' 
              ';' ttblAm2.amTempF skip.  
        accumulate ttblAm2.amBBal     (TOTAL).
        accumulate ttblAm2.amIn       (TOTAL).
        accumulate ttblAm2.amOut      (TOTAL).
        accumulate ttblAm2.amTemp     (TOTAL).
        accumulate ttblAm2.amTempPrec (TOTAL).
        accumulate ttblAm2.amTempR    (TOTAL).
        accumulate ttblAm2.amTempRInc (TOTAL).   
        accumulate ttblAm2.am100MRP    (TOTAL).   
        accumulate ttblAm2.amTempF    (TOTAL).   
    end.
    
    put unformatted ';' ';' ';' ';' ';' ';'
        (accum TOTAL ttblAm2.amBBal)       ';'
        (accum TOTAL ttblAm2.amIn)         ';'
        (accum TOTAL ttblAm2.amOut)        ';'
        (accum TOTAL ttblAm2.amTemp)       ';'
        (accum TOTAL ttblAm2.amTempPrec)   ';'
        (accum TOTAL ttblAm2.amTempR)      ';'
        (accum TOTAL ttblAm2.amTempRInc)   ';' 
        (accum TOTAL ttblAm2.am100MRP)     ';' ';'
        (accum TOTAL ttblAm2.amTempF)      
        skip.
    
    output close.
  
    run menu-prt('ast2.csv').
    unix silent rm ast2.csv.
  END.

  WHEN 4 THEN
  DO:

    output to 'astfull.csv'.
  
    put 'Номер' ';' 'Наименование' ';' 'Дата ввода' ';' 'Группа' ';' 'Подруппа' ';' 'На начало года' ';' 'Поступл.' ';' 'Выбытие' ';' ';' ';' 'Ремонт' skip.
  
    for each tblFull where tblFull.fAmr2 = false break by tblFull.fCat by tblFull.fSubCat:

        if first-of(tblFull.fSubCat) 
           then 
             do:
                for each btbl where btbl.fAmr2 = false
                                   and tblFull.fCat = btbl.fCat
                                   and tblFull.fSubCat = btbl.fSubCat :
                    aTemp = (btbl.fBamt + btbl.fIn - btbl.fOut) * btbl.fRepair .
                    accum aTemp (total).
                end.
                TempSum = accum total aTemp.

                find first ttblAm where ttblAm.cat = tblFull.fCat and ttblAm.subcat = tblFull.fSubCat no-error. /* найти параметры категории !! */
                if avail ttblAm then 
                                  do: 
                                     put unformatted ttblAm.catname skip.   /* вывести заголовки !!*/
                                     if ttblAm.amTempRInc <> 0 then 
                                        do:
                                           aRepSum = ttblAm.amRepair.
                                           for each bTbl where bTbl.fCat = tblFull.fCat and bTbl.fSubCat = tblFull.fSubCat:
                                               aTemp = bTbl.fBamt + bTbl.fIn - bTbl.fOut.
                                               aTempPrec = aTemp / 100 * bTbl.fPrec. /* считаем амортизацию */
                                               aTemp15 = (aTemp - aTempPrec) / 100 * 15. /* допустимый предел суммы на ремонт */
                                               if bTbl.fRepair <= aTemp15 then aRepSum = aRepSum - ttblAm.amRepair.
                                           end.
                                        end.
                                  end.
             end.


        aTemp = tblFull.fBamt + tblFull.fIn - tblFull.fOut.
        aTempPrec = aTemp / 100 * tblFull.fPrec.  /* считаем амортизацию */

        if ttblAm.amTempRInc = 0 
          then
            do: 
               aTempR = tblFull.fRepair.
               aTempRInc = 0.
               aTempF = aTemp - aTempPrec.
            end.
          else
            do:
               aTempRInc = aTemp * tblFull.fRepair / TempSum * ttblAm.amTempRInc .
               aTempR = tblFull.fRepair - aTempRInc .
               aTempF = aTemp - aTempPrec + aTempRInc.
/*               
               aTemp = tblFull.fBamt + tblFull.fIn - tblFull.fOut.
               aTempPrec = aTemp / 100 * tblFull.fPrec. 
               aTemp15 = (aTemp - aTempPrec) / 100 * 15. 
               if tblFull.fRepair > aTemp15 
                  then
                    do:
                       aTempRInc = (aRepSum * (tblFull.fRepair - aTemp15)) / tblFull.fRepair.
                       aTempR = tblFull.fRepair - aTempRInc.
                    end. */
            end.

        accumulate tblFull.fBamt      (SUB-TOTAL by tblFull.fSubCat).
        accumulate tblFull.fIn        (SUB-TOTAL by tblFull.fSubCat).
        accumulate tblFull.fOut       (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTemp      (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTempPrec  (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTempR     (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTempRInc  (SUB-TOTAL by tblFull.fSubCat).   
        accumulate         aTempF     (SUB-TOTAL by tblFull.fSubCat).   

        put unformatted tblFull.fAst ';' tblFull.fName ';' tblFull.fRdt ';' tblFull.fCat ';' tblFull.fSubCat ';'  tblFull.fBamt ';' tblFull.fIn ';' 
                        tblFull.fOut ';' aTemp ';' aTempPrec ';' aTempR ';' aTempRInc ';' ';' ';' aTempF skip.

        if last-of(tblFull.fSubCat) 
           then 
             do:
                 put unformatted 'ИТОГО: ' ';' ';' ';' ';' ';' 
                    (accum SUB-TOTAL by tblFull.fSubCat tblFull.fBamt)     /*    format 'zzz,zzz,zzz.99-' */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat tblFull.fIn)       /*    format 'zzz,zzz,zzz.99-' */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat tblFull.fOut)      /*     format 'zzz,zzz,zzz.99-'*/ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTemp)     /*   format 'zzz,zzz,zzz.99-'  */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempPrec) /*   format 'zzz,zzz,zzz.99-'  */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempR)    /*   format 'zzz,zzz,zzz.99-'  */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempRInc) /*   format 'zzz,zzz,zzz.99-'  */ ';' ';' ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempF)    /*   format 'zzz,zzz,zzz.99-'  */
                    skip.                                                                
             end.
    end.
  
    output close.
  
    run menu-prt('astfull.csv').
    unix silent rm astfull.csv.
  END.

  WHEN 5 THEN
  DO:

    output to 'astfull2.csv'.
  
    put 'Номер' ';' 'Наименование' ';' 'Дата ввода' ';' 'Группа' ';' 'Подруппа' ';' 'Норма амортизации' ';' 'Двойная амортизация' ';' 
            'На начало года' ';' 'Поступл.' ';' 'Выбытие' ';' ';' ';' 'Ремонт' skip.
  
    for each tblFull where tblFull.fAmr2 = true break by tblFull.fCat by tblFull.fSubCat:

        if first-of(tblFull.fSubCat) 
           then 
             do:
                find first ttblAm2 where ttblAm2.cat = tblFull.fCat and ttblAm2.subcat = tblFull.fSubCat no-error. 
                if avail ttblAm2 then 
                                  do: 
                                     put unformatted ttblAm2.catname skip.
                                     if ttblAm2.amTempRInc <> 0 then 
                                        do:
                                           aRepSum = ttblAm2.amRepair.
                                           for each bTbl where bTbl.fCat = tblFull.fCat and bTbl.fSubCat = tblFull.fSubCat:
                                               aTemp = bTbl.fBamt + bTbl.fIn - bTbl.fOut.
                                               aTempPrec = aTemp / 100 * (bTbl.fPrec * 2). /* считаем амортизацию */
                                               aTemp15 = (aTemp - aTempPrec) / 100 * 15. /* допустимый предел суммы на ремонт */
                                               if bTbl.fRepair <= aTemp15 then aRepSum = aRepSum - ttblAm2.amRepair.
                                           end.
                                        end.
                                  end.
             end.


        aTemp = tblFull.fBamt + tblFull.fIn - tblFull.fOut.
        aTempPrec = aTemp / 100 * (tblFull.fPrec * 2).  /* считаем амортизацию */

        aTempR = 0.
        aTempRInc = 0.
        aTempF = aTemp - aTempPrec.


        accumulate tblFull.fBamt      (SUB-TOTAL by tblFull.fSubCat).
        accumulate tblFull.fIn        (SUB-TOTAL by tblFull.fSubCat).
        accumulate tblFull.fOut       (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTemp      (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTempPrec  (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTempR     (SUB-TOTAL by tblFull.fSubCat).
        accumulate         aTempRInc  (SUB-TOTAL by tblFull.fSubCat).   
        accumulate         aTempF     (SUB-TOTAL by tblFull.fSubCat).   

        put unformatted tblFull.fAst    ';' 
                        tblFull.fName   ';' 
                        tblFull.fRdt    ';' 
                        tblFull.fCat    ';' 
                        tblFull.fSubCat ';' 
                        tblFull.fPrec   ';' 
                        tblFull.fPrec * 2 ';'
                        tblFull.fBamt   ';' 
                        tblFull.fIn     ';' 
                        tblFull.fOut    ';' 
                        aTemp           ';' 
                        aTempPrec       ';' 
                        aTempR          ';' 
                        aTempRInc       ';' ';' ';' 
                        aTempF skip.

        if last-of(tblFull.fSubCat) 
           then 
             do:
                 put unformatted 'ИТОГО: ' ';' ';' ';' ';' ';' ';' ';' 
                    (accum SUB-TOTAL by tblFull.fSubCat tblFull.fBamt)     /*    format 'zzz,zzz,zzz.99-' */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat tblFull.fIn)       /*    format 'zzz,zzz,zzz.99-' */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat tblFull.fOut)      /*     format 'zzz,zzz,zzz.99-'*/ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTemp)     /*   format 'zzz,zzz,zzz.99-'  */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempPrec) /*   format 'zzz,zzz,zzz.99-'  */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempR)    /*   format 'zzz,zzz,zzz.99-'  */ ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempRInc) /*   format 'zzz,zzz,zzz.99-'  */ ';' ';' ';'
                    (accum SUB-TOTAL by tblFull.fSubCat aTempF)    /*   format 'zzz,zzz,zzz.99-'  */
                    skip.                                                                
             end.
    end.
  
    output close.
  
    run menu-prt('astfull2.csv').
    unix silent rm astfull2.csv.
  END.


  END CASE.
  report-type = 0.
END.

    display '   Ждите...   ' with row 5 frame fr4 centered.

for each comm.txb where comm.txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb". 
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    do:
       run amr_rech.
    end.
end.
    
if connected ("txb") then disconnect "txb".

pause 0.

find last astmrp where astmrp.r-year = STRING(YEAR(TODAY)) no-lock no-error.
output to 'spis.txt'.


astFrom  = '31000197,31100093,32000069,34000062,46100005,51100011,51100024,60400147,60400230,60400231,60400232'.
astTo    = '31000007,31100008,32000004,34000003,46100001,51100033,51100034,60400385,60400386,60400387,60400388'.
astfCode = '194901964,194901964,194901964,194901964,194901964,195301973,195301973,195301973,195301973,195301973,195301973'.

for each tblFull:
    if tblFull.fIn = 0 and tblFull.fBAmt = 0
       then
         do:
            delete tblFull.
         end.
end.

for each tblFull:
    if lookup(tblFull.fAst,astFrom) <> 0
       then
         do:
            find bTbl where bTbl.fAst = entry(lookup(tblFull.fAst,astFrom),astTo) and bTbl.fCode = entry(lookup(tblFull.fAst,astFrom),astfCode).
            if avail bTbl then do:
            /**************************************************/
                             bTbl.fIn = tblFull.fbAmt.
                             bTbl.fAmr2  = false.
                          end.
                     else message "Ошибка не найдено соответствие" view-as alert-box.
         end.
    /* выбытие должно быть равно первоначальной стоимости */
    if (tblFull.fBAmt <> 0) and (tblFull.fBAmt < tblFull.fOut) 
       then tblFull.fOut = tblFull.fBAmt.
       else
         if (tblFull.fBAmt <> 0) and (tblFull.fBAmt > tblFull.fOut) and (tblFull.fOut <> 0)
            then /*display tblFull with width 150.*/ tblFull.fOut = tblFull.fBAmt.

end.

output close.
                                                                                   
for each ttblAm /*break by tblFull.fCat by tblFull.fSubCat*/:
    for each tblFull where tblFull.fCat = ttblAm.cat and tblFull.fSubCat = ttblAm.subcat and tblFull.fAmr2 = false:
        ttblAm.amBBal = ttblAm.amBBal + tblFull.fBAmt.
        ttblAm.amIn = ttblAm.amIn + tblFull.fIn.
        ttblAm.amOut = ttblAm.amOut + tblFull.fOut.
        ttblAm.amRepair = ttblAm.amRepair + tblFull.fRepair.
    end.
/*    if last-of(tblFull.fSubCat)*/
end.



for each ttblAm2 /*break by tblFull.fCat by tblFull.fSubCat*/:
    for each tblFull where tblFull.fCat = ttblAm2.cat and tblFull.fSubCat = ttblAm2.subcat and tblFull.fAmr2 = true:
        ttblAm2.amBBal = ttblAm2.amBBal + tblFull.fBAmt.
        ttblAm2.amIn = ttblAm2.amIn + tblFull.fIn.
        ttblAm2.amOut = ttblAm2.amOut + tblFull.fOut.
        ttblAm2.amRepair = 0 .
    end.
end.


for each ttblAm:
           aTemp = ttblAm.amBBal + ttblAm.amIn - ttblAm.amOut.
           aTempPrec = aTemp / 100 * ttblAm.amPrec.
           aTemp15 = (aTemp - aTempPrec) / 100 * 15.
           ttblAm.amTemp = aTemp.
           ttblAm.amTempPrec = aTempPrec.
           if aTemp15 < ttblAm.amRepair 
              then 
                do:
                  aTempRInc = ttblAm.amRepair - aTemp15.
                  aTempR = aTemp15.

/*                  aTempR = aTemp15.
                  aTempRInc = ttblAm.amRepair - aTemp15.
                  aTempF = aTemp + ttblAm.amRepair - aTemp15 - aTempPrec.   */
                end.
              else 
                do:
                  aTempR = ttblAm.amRepair.
                  aTempRInc = 0.
                  aTempF = aTemp - aTempPrec.
                end.
           ttblAm.amTempR    =  aTempR.
           ttblAm.amTempRInc =  aTempRInc.
           if avail astmrp then 
              if aTemp < astmrp.r-sum * 100 then 
                 do:
                    ttblAm.am100MRP = aTempF.
                    aTempF = 0.
                 end.
           ttblAm.amTempF    =  aTempF.
end.

for each ttblAm2:
           aTemp = ttblAm2.amBBal + ttblAm2.amIn - ttblAm2.amOut.
           aTempPrec = aTemp / 100 * (ttblAm2.amPrec).
           aTemp15 = (aTemp - aTempPrec) / 100 * 15.
           ttblAm2.amTemp = aTemp.
           ttblAm2.amTempPrec = aTempPrec.
           if aTemp15 < ttblAm2.amRepair 
              then 
                do:
                  aTempRInc = ttblAm.amRepair - aTemp15.
                  aTempR = aTemp15.

/*                  aTempR = aTemp15.
                  aTempRInc = ttblAm.amRepair - aTemp15.
                  aTempF = aTemp + ttblAm.amRepair - aTemp15 - aTempPrec.   */
                end.
              else 
                do:
                  aTempR = ttblAm2.amRepair.
                  aTempRInc = 0.
                  aTempF = aTemp - aTempPrec.
                end.
           ttblAm2.amTempR    =  aTempR.
           ttblAm2.amTempRInc =  aTempRInc.
           if avail astmrp then 
              if aTemp < astmrp.r-sum * 100 then 
                 do:
                    ttblAm2.am100MRP = aTempF.
                    aTempF = 0.
                 end.
           ttblAm2.amTempF    =  aTempF.
end.


output close.

/*
output to log.log.

for each tblFull:
    display tblFull.
end.

output close.
*/

ENABLE ALL WITH FRAME af1.

WAIT-FOR CHOOSE OF aexit.

SESSION:NUMERIC-FORMAT = 'American'.


