/* taxtns.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/


/* KOVAL Ввод справки по транспортному налогу */
/* taxtns(g-today,tax.dnum,tax.rnn:screen-value,FIOonly,ADROnly). */
def input parameter dat as date.

{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def shared var tValidRnn as logical initial false.
def shared var ADRonly  as char.
def shared var FIOonly  as char.
def shared var FIO      as char.
def shared var docrnn   as char.
def shared var docrnnnk as char.
def shared var docnum as integer.
def shared var kbchar as char.
def shared var numtns as integer.
def shared var tsum   as decimal.
def shared var bsdate as date.
def shared var esdate as date.
def shared var riddolg as char.

def var tDolg  as logical.
def var autocnt as integer.
def var rid as rowid.

def var choice2 as logical initial false.
def var evnt    as logical initial false.
def var TVALID  as logical initial false.

def var mark as int.
def var cret as char init "".
def var s-rnn   as char init "".
def var rids    as char initial "".
def var nkname  as char.
def var sumchar as char.
def var sumchar1 as char.
def var sumchar2 as char.
def var comchar  as char.
def var receiver as char.
                  
def var tEngine as decimal format "9999999.9" init 0. /* Технич.характеристика */
def var tEdizm  as char format "x(4)" init "".        /* Едизм */
/*
def var VolEngine as decimal format "9999999.9" init 0.
def var Capacity  as decimal format "9999999.9" init 0.
def var NumPlaces as decimal format "9999999.9" init 0.
def var Power     as decimal format "9999999.9" init 0. 
*/
def var tModel    as char format "x(40)".
def var tDovDate  as date.
def var tDovAdr   as char format "x(60)".
def var tDovNum   as char format "x(8)".
def var tNumber   as char format "x(9)".
def var tYear     as char format "x(13)".
def var tPspSer   as char format "x(3)".
def var tPspNum   as char format "x(8)".
def var tPspDate  as date.

def var lcom as logical init false.
def var chbegin-ret as logical init false.
def var cdate as date init today.

     def var deadline as date init 07/01/02.
     def var delta as integer.
     def var newfine as decimal init 0.00.

/* 
define buffer btns for tns.
define buffer btax for tax.
define buffer btaxauto for comm.taxauto. 
*/

{yes-no.i}

define button findbtn label 'Поиск'.

def frame tnsframe
    docrnn  at 1 format "999999999999" label "РНН" skip
    "N" numtns view-as text format ">>>>>>>9" FIOonly format "x(50)" label "Дана" skip
    ADRonly at 1 format "x(53)" label "Адрес владельца" skip
    "Адрес владельца по доверенности N " tdovnum " от " tdovdate skip
    tdovadr format "x(60)" skip
    "Марка а/м "  tModel format "x(50)" skip
    "Гос. номер " tNumber format "x(9)" "Год выпуска " tYear format "x(13)" skip(1)
    "Технич. характеристика: " tEngine format ">>>>>>9.9" " " tEdizm format "x(8)" skip(1)

    "СРТС : серии " tpspser "N" tpspnum " от " tpspdate skip(1)

    "Владелец автотранспорта за 2002 год оплатил(а) налог на транспортное средство." skip 

    "Сумма" tsum format ">,>>>,>>9.99" " в т.ч. пеня " newfine format ">>>,>>9.99" space(3) "Дата уплаты" dat view-as text skip(1)
/*    "Квитанция N " docnum format ">>>>>9" view-as text */ skip
    "Получатель " receiver format "x(40)" skip(2)
    with no-labels centered.

    on help of docrnn in frame tnsframe do:
        run taxfind.
        if return-value <> "" then do:
            update docrnn:screen-value = return-value with frame tnsframe.
            update docrnn = return-value with frame tnsframe.
        end.    
        apply "value-changed" to self.
    end.
                    
    on help of tModel in frame tnsframe do:
        run chbegin(output chbegin-ret).
        if not chbegin-ret then return.
        apply "value-changed" to self.
    end.

    on help of tNumber in frame tnsframe do:
        run fndnum.
        apply "value-changed" to self.
    end.

    on help of receiver in frame tnsframe  do:
        run taxnk.
        if return-value <> "" then do:
            find first taxnk where taxnk.rnn = return-value no-lock no-error.
            docrnnnk = return-value.
            receiver = taxnk.name.
            displ receiver with frame tnsframe.
        end.
        apply "value-changed" to self.
    end.

   on value-changed of docrnn in frame tnsframe do:
        docrnn = docrnn:screen-value.
        find first rnn where rnn.trn = docrnn USE-INDEX rnn no-lock no-error.
        if avail rnn then do:
            tValidrnn = true.
            fio = trim( rnn.lname ) + " " + trim( rnn.fname ) + " " +
            trim( rnn.mname ) + ", " + rnn.street1 + ", " + 
            rnn.housen1 + "/" + rnn.apartn1.
            FIOonly = caps(trim( rnn.lname ) + " " + trim( rnn.fname ) + " " +
            trim( rnn.mname )).
            ADRonly = caps(trim(rnn.street1) + ", " + rnn.housen1 + "/" + rnn.apartn1).
        end.
        else do: 
            find first rnnu where rnnu.trn = docrnn:screen-value USE-INDEX rnn
            no-lock no-error.
            if avail rnnu then do:
                tvalidrnn = true.
                fio = caps(trim( rnnu.busname )) + ", " + rnnu.street1 + ", " +
                rnnu.housen1 + "/" + rnnu.apartn1.
                FIOonly = caps(trim(rnnu.busname)).
                ADRonly = caps(trim(rnn.street1) + ", " + rnnu.housen1 + "/" + rnnu.apartn1).

            end.
            else do:              
                tvalidrnn = false.
                fio = ''.
            end.
      end. 
    display fioonly docrnn adronly with frame tnsframe. 
   end.
/*
on value-changed of receiver in frame tnsframe do:
        displ receiver with frame tnsframe.
end.
*/

/* Main Logic */

      choice2 = false.
      TValid  = false.
      tEdizm  = "".
      tEngine = 0.

      if numtns = 0 or numtns = ? then  do: /* Если новый докумет, то ищем по РНН автомобиль */

              find first tnsdolg where tnsdolg.rnn = docrnn and uid = ? no-lock no-error.
              if avail tnsdolg then do:
                                    tdolg = true.
                                    run dolg.
                                    return.
                                   end.
        run chbegin(output chbegin-ret).
        end.

        else do:               /* Если введен документ, то ищем автомобиль in tns table */
          find first tns where tns.tns = numtns use-index tns no-error.
          IF AVAILABLE(tns) then do:
               TValid  = true.
               assign
                   FIOOnly   = tns.fio
                   ADROnly   = tns.adr
                   docrnn    = tns.rnn
                   tdovnum   = tns.dovnum
                   tdovdate  = tns.dovdate
                   tdovadr   = tns.dovadr
                   tModel    = tns.Model
                   tpspser   = tns.pspser
                   tpspnum   = tns.pspnum
                   tpspdate  = tns.pspdate
                   tsum      = tns.sum
                   tyear     = tns.year
                   tNumber   = tns.Number
                   receiver  = tns.nkname
                   bsdate    = tns.bdate 
                   esdate    = tns.edate
                   tEngine   = tns.Engine  
                   tEdizm    = tns.Edizm  no-error.

           end. /* If available */
           else do: 
                end.    /* MESSAGE "Введенная раннеe справка не найдена ???!"
                           VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                           TITLE "Транспортный налог" . */
      end.      /* if numtns <> 0 */

 
      find first taxnk where taxnk.rnn = docrnnnk no-lock no-error.
      if avail taxnk then assign receiver = taxnk.name no-error.
                     else assign receiver = "" no-error.
      apply "value-changed" to receiver in frame tnsframe.

     /*** KOVAL Расчет суммы пени после 1 июля ***/
     delta = dat - deadline + 1.

     if delta > 0 then do:
          newfine = (tsum * 0.08 * 1.5 * delta) / 365.
          message "Т.к. оплата налога произведена с 01.07.2002, ~nначисляем пеню в размере" +
          string(newfine,"->>>,>>>,>>9.99") + "~nна сумму тр.налога " + string(tsum,"->>>,>>>,>>9.99")
          view-as alert-box.
          tsum = tsum + newfine.
     end. 

     /*** KOVAL ***/
        
        
        display numtns FIOonly docrnn ADRonly
                tdovnum tdovdate tdovadr tModel 
                tEngine tEdizm
                tpspser tpspnum tpspdate dat tsum newfine   
                WITH side-labels FRAME tnsframe.
        
               update 
                      docrnn validate( can-find( first comm.rnn where   comm.rnn.trn = docrnn no-lock) or
                                       can-find( first comm.rnnu where comm.rnnu.trn = docrnn no-lock) or
                                       length(docrnn) = 12 and
                                       yes-no("", "РНН не найден в справочнике.~nПродолжить с введенным РНН?"),
                                                  "Не верный РНН")
                      fioonly
                      adronly
                      tdovnum
                      tdovdate 
                      tdovadr 
                      tModel 
                      tNumber
                      tYear
                      tEngine
                      tEdizm
/*                      bsdate
                      esdate*/
                      tpspser 
                      tpspnum 
                      tpspdate 
/*                      tsum*/
                      receiver
                      WITH FRAME tnsframe editing:
                        readkey.
                        apply lastkey.
                        if frame-field = "docrnn" then apply "value-changed" to docrnn in frame tnsframe.      
                      end.                  

                MESSAGE "Сохранить справку ?"
                     VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                     TITLE "Транспортный налог" UPDATE choice2 .
                case choice2:
                    when true then 
                      do transaction:
                         if (numtns = 0 or numtns = ?) then do:
                            create tns no-error.
                            numtns = next-value(tnsg,comm).
                          end.
/*                          else find first tns where tns.tns = numtns use-index tns no-lock no-error.*/
                         assign  
                                  tns.codenk   = substr(docrnnnk,1,4)
                                  tns.fio      = FIOOnly
                                  tns.ADR      = ADROnly
                                  tns.rnn      = docrnn 
                                  tns.year     = tyear  
                                  tns.number   = tNumber
                                  tns.tns      = numtns  
                                  tns.dovnum   = tdovnum 
                                  tns.dovdate  = tdovdate
                                  tns.dovadr   = tdovadr    
                                  tns.Model    = tModel      
                                  tns.pspser   = tpspser     
                                  tns.pspnum   = tpspnum       
                                  tns.pspdate  = tpspdate       
                                  tns.sum      = tsum            
                                  tns.nkname   = receiver 
                                  tns.bdate    = bsdate
                                  tns.edate    = esdate 
                                  tns.Engine   = tEngine
                                  tns.Edizm    = tEdizm 
                                  tns.txb      = ourcode no-error.
                    end.    
                end case.

hide frame tnsframe.

return string(tsum).







Procedure chbegin:
def output parameter ret as log.

 DEFINE QUERY q1 FOR comm.taxauto.

 def browse b1 
    query q1 no-lock
    display 
        comm.taxauto.rnn    label "РНН" format 'x(12)'
        comm.taxauto.model  label "Модель" format 'x(13)'
        comm.taxauto.number label "Номер" format 'x(9)'
        comm.taxauto.year   label "Год" format 'x(4)'
        comm.taxauto.bdate  label "   Дата" format '99/99/99'
        comm.taxauto.edate  label "владения" format '99/99/99'
        comm.taxauto.sum    label "Сумма" format ">>>,>>9.99"
        with no-labels 7 down title "Выберите автомобиль".

 def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
 on return of b1 in frame fr1
    do: 
      rid = rowid(comm.taxauto).
      find first comm.taxauto where rowid(taxauto) = rid no-lock no-error.
      TValid  = false.

       assign
         tModel   = comm.taxauto.Model
         tsum     = comm.taxauto.sum
         tyear    = comm.taxauto.year
         tNumber  = comm.taxauto.Number
         bsdate   = comm.taxauto.bdate
         esdate   = comm.taxauto.edate
         tEngine  = comm.taxauto.Engine   
         tEdizm   = comm.taxauto.Edizm no-error.
 
      apply "endkey" to frame fr1.
    end.  
                    
 open query q1 for each comm.taxauto where comm.taxauto.rnn = docrnn.

 autocnt = num-results("q1").

 if autocnt = 0 then do:
    MESSAGE "Записи в базе автомобилей для этого РНН не найдены." docrnn
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Не найден автомобиль".
    rid = ?.  
    ret = false. 
    return.
 end.
 else do:
      TValid  = true.
      b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
      ENABLE all with frame fr1.
      apply "value-changed" to b1 in frame fr1.
      WAIT-FOR endkey of frame fr1.
 end.

 hide frame fr1.
       if substring(docrnnnk,1,4) <> comm.taxauto.codenk then
          MESSAGE "Автомобиль зарегистрирован в налоговой " codenk ", "
                  "а заполняете для " substring(docrnnnk,1,4)
                     VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                     TITLE "Транспортный налог".

 display numtns tModel TNUMBER tyear tEngine tEdizm
         tsum receiver
         WITH side-labels FRAME tnsframe.
 ret = true.
end.



procedure fndnum.
 DEFINE QUERY q1 FOR comm.taxauto.

 def browse b1 
    query q1 no-lock
    display 
        comm.taxauto.rnn    label "РНН" format 'x(12)'
        comm.taxauto.model  label "Модель" format 'x(20)'
        comm.taxauto.number label "Номер" format 'x(9)'
        comm.taxauto.year   label "Год" format 'x(13)'
        comm.taxauto.sum    label "Сумма" format ">>>,>>9.99"
        with no-labels 7 down title "Выберите автомобиль".

 def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
 on return of b1 in frame fr1
    do: 
      rid = rowid(taxauto).
      find first taxauto where rowid(taxauto) = rid no-lock no-error.
      TValid  = false.

       assign
         tModel   = comm.taxauto.Model
         tsum     = comm.taxauto.sum
         tyear    = comm.taxauto.year
         tNumber  = comm.taxauto.Number
         bsdate   = comm.taxauto.bdate
         esdate   = comm.taxauto.edate
         tEngine  = comm.taxauto.Engine   
         tEdizm   = comm.taxauto.Edizm 
         no-error.

       apply "endkey" to frame fr1.
    end.  
                    
 open query q1 for each taxauto where comm.taxauto.number = tNumber:screen-value in frame tnsframe.

 autocnt = num-results("q1").

 if autocnt = 0 then do:
    MESSAGE "Записи в базе автомобилей для этого номера не найдены." docrnn
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Не найден автомобиль".
    rid = ?.                 
 end.
 else do:
      TValid  = true.
      b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
      ENABLE all with frame fr1.
      apply "value-changed" to b1 in frame fr1.
      WAIT-FOR endkey of frame fr1.
 end.

hide frame fr1.

display numtns tModel tNUMBER tyear tEngine tEdizm
        tsum WITH side-labels FRAME tnsframe.
end PROCEDURE.



procedure dolg.
 DEFINE QUERY qq1 FOR tnsdolg.

 def browse b1 
    query qq1 no-lock
    display 
        tnsdolg.codenk label " НК"   format 'x(4)'
        tnsdolg.date   label "Дата"  format '99/99/99'
        tnsdolg.RNN    label "    РНН" format 'x(12)'
        tnsdolg.Sum    label "Задолженность" format ">,>>>,>>9.99"
        tnsdolg.Fine   label "Пеня" format ">>>,>>9.99"
        tnsdolg.Sum + tnsdolg.Fine label "Всего" format ">,>>>,>>9.99"
        with no-labels 7 down title " Нажмите на клавишу Enter для оплаты ".

 def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
 on return of b1 in frame fr1
    do: 
      rid = rowid(tnsdolg).
      find first tnsdolg where rowid(tnsdolg) = rid no-lock no-error.
      if avail tnsdolg then do:
         tsum = tnsdolg.sum + tnsdolg.fine.

         riddolg = string(rowid(tnsdolg)).

        find first taxnk where substring(taxnk.rnn,1,4) = tnsdolg.codenk no-lock no-error.
        if avail taxnk then assign docrnnnk = taxnk.rnn no-error.
                       else assign docrnnnk = "" no-error.
       apply "endkey" to frame fr1.
      end.   
    end.  
                    
 open query qq1 for each tnsdolg where tnsdolg.rnn = docrnn and uid = ?.

 autocnt = num-results("qq1").

 if autocnt = 0 then tdolg = false.
 else do:
      tdolg = true.
      b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
      ENABLE all with frame fr1.
      apply "value-changed" to b1 in frame fr1.
      WAIT-FOR endkey of frame fr1.
 end.

end PROCEDURE.
 




