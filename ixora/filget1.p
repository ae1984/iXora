/* filget1.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Снятие со счета в другом филиале
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        24.06.2010 marinav galina denis
 * CHANGES
        20/10/2011 evseev - добавил код комиссии 302
        25/01/2012 evseev - ТЗ-1245
        23.05.2012 evseev - ТЗ-1366 запрет на операцию если не акцептован клиент
        06.08.2012 dmitriy - внес изменения в поиск чековых книжек
        31.08.2012 evseev - иин/бин
        25/09/2012 dmitriy - выбор номера чека через F2
        03/10/2012 dmitriy - сообщение "Данный чек уже использован" только для чеков, зарегистрированных после 25/09/2012
        27.11.2012 Lyubov - исправила выход по F4 в 251 строке
        27.11.2012 Lyubov - ТЗ №1521, проверка наличия ИИН/БИН, при отсутсвии - сообщение, после 01.01.13 - выход из программы
        20/05/2013 Luiza  - ТЗ 1309 льготные тарифы при межфилиальных платежах
        21/05/2013 Luiza  - ТЗ 1841.
*/

def  shared var v-cif-f as char.
def  shared var v-bankname as char.
def  shared var v-iik like bank.aaa.aaa.
def  shared var v-crc like bank.crc.crc.
def  shared var v-crc_val as char no-undo format "xxx".
def  shared var v-fio as char no-undo format "x(60)".
def  shared var v-rnn like bank.cif.jss.
def  shared var v-pss as char no-undo format "x(30)".

def  shared var v-fio1 as char no-undo format "x(60)".
def  shared var v-rnn1 like bank.cif.jss.
def  shared var v-pss1 as char no-undo format "x(30)".

def  shared var v-sum as deci no-undo.
def  shared var v-kod as char no-undo init "19".
def  shared var v-kbe as char no-undo init "19".
def  shared var v-knp as char no-undo.
def  shared var v-codename as char no-undo .
def  shared var v-com as char no-undo.
def  shared var v-sum_com as deci no-undo.
def  shared var v-npl as char.
def  shared var v-npl1 as char.

def  shared var v-ja as logi no-undo format "Да/Нет" init no.
def  shared var v-tit as char.
def  shared var v-comkod as char.
def  shared var v-type as char.
def  shared var v-mail as char.
def  shared var v-gtoday as date no-undo.
def  shared var v-fu as char.
def  shared var v-chk as integer format ">>>>>>>>>>9" .

def var v-whplat as logic.
def var v-chr as char.

def var v-ser as char init "".

def var i_mk as integer.
def var vavl as deci.
def buffer baaa for txb.aaa.

/* для комиссии*/
def var v-amt as decim.
def var tproc as decim.
def var pakal as char.


def temp-table t-ln no-undo
    field code as char
    field name as char format "x(70)"
    index main is primary code.

define temp-table wrk-chk
    field chk as char
    index idx is primary chk ascending.

for each t-ln. delete t-ln. end.

{chk12_innbin.i}

/*БИН   */
def var v-bin as logi init no.
def var v-label as char format "x(18)".
def var v-label1 as char format "x(18)".
find first txb.sysc where txb.sysc.sysc = 'bin' no-lock no-error.
if avail txb.sysc then v-bin = txb.sysc.loval.
if v-bin  then v-label = "ИИН/БИН          :". else v-label =   "РНН/БИН клиента  :".
if v-bin  then v-label1 = "ИИН/БИН получ.   :". else v-label1 = "РНН получателя   :".

for each txb.codfr where txb.codfr.codfr = 'spnpl' no-lock .
    create t-ln.
    t-ln.code =  txb.codfr.code.
    t-ln.name = txb.codfr.name[1] + txb.codfr.name[2].
end.
form  skip(1)
    v-iik label "Счет клиента     " format "x(20)" skip
    v-crc label "Валюта           "   v-crc_val no-label skip
    v-fio label "Клиент           " format "x(50)" skip
    v-label no-label v-rnn no-label validate((chk12_innbin(v-rnn)),'Неправильно введён БИН/ИИН') colon 18 skip
    v-pss label "Уд. личн.        "  skip
    v-chk label "Номер чек кн     "  format "9999999" validate(can-find(first txb.checks where txb.checks.nono <= v-chk and txb.checks.lidzno >= v-chk no-lock),"Неверный номер чека") skip
    v-ser label "       Серия     " format "x(2)" validate(can-find(first txb.checks where txb.checks.ser = v-ser no-lock),"Неверный номер серии") skip
    v-sum label "Сумма            " format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-fio1 label "ФИО получателя   " format "x(50)" skip
    v-pss1 label "Документ         "  skip
    v-label1 no-label v-rnn1 no-label validate((chk12_innbin(v-rnn1)),'Неправильно введён БИН/ИИН') colon 18  skip
    v-kod label "Код              " format "x(2)" validate(v-kod ne "" , "Введите Код!") skip
    v-kbe label "Кбе              " format "x(2)" validate(v-kod ne "" , "Введите Кбе!") skip
    v-knp label "КНП              " format "x(3)" validate( can-find (t-ln where t-ln.code = v-knp) , "Введите КНП! См. справочник (F2)") help "F2 - справочник" v-codename no-label format "x(40)" skip
    v-com label     "Комиссия         " format "x(3)" validate(lookup(v-com, v-comkod) > 0, "Допустимы кода " + v-comkod + " !") skip
    v-sum_com label "Сумма комиссии   " format ">>>,>>9.99"  skip(1)
  '----------------------------Назначение платежа---------------------------' at 5 skip(1)
    v-npl  no-label format "x(78)"  skip
    v-npl1 no-label format "x(78)"  skip(2)

    v-ja label "Формировать транзакцию?   " skip(1)
with centered side-label row 7 width 80 overlay  title v-tit +  v-bankname frame fr1.


form
    v-chr no-label format "x(1)" skip(1)
   'u - Уполномоченные лица, n - наследнк ' at 5 skip(1)
with centered side-label row 7 width 80 overlay  title "Задайте параметр" frame fr3.
form
    v-chr no-label format "x(1)" skip(1)
   'u - Уполномоченные лица, t - третье лицо ' at 5 skip(1)
with centered side-label row 7 width 80 overlay  title "Задайте параметр" frame fr4.

form
    v-chr no-label format "x(1)" skip(1)
   'u - Уполномоченные лица, r - первый руководитель, b - главный бухгалтер' at 5 skip(1)
with centered side-label row 7 width 80 overlay  title "Задайте параметр" frame fr5.


on help of v-knp in frame fr1 do:
    {itemlist.i
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 20 down overlay "
       &where = " true "
       &flddisp = " t-ln.code label 'КОД' format 'x(3)'  t-ln.name label 'НАЗВАНИЕ' format 'x(70)' "
       &chkey = "code"
       &chtype = "string"
       &index  = "main"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
    }
    v-knp = t-ln.code.
    displ v-knp with frame fr1.
end.

/*----------- выбор номера ЧК -----------------*/

        def var v-book as int.
        def var i as int.
        DEFINE QUERY q-book FOR txb.checks.

        DEFINE BROWSE b-book QUERY q-book
               DISPLAY txb.checks.nono txb.checks.lidzno label "Выбор ЧК"
               WITH  15 DOWN.
        DEFINE FRAME f-book b-book  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 40 width 25 NO-BOX.

        DEFINE QUERY q-chk FOR wrk-chk.

        DEFINE BROWSE b-chk QUERY q-chk
               DISPLAY wrk-chk.chk label "№ чека " format "x(7)"
               WITH  15 DOWN.
        DEFINE FRAME f-chk b-chk  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 62 width 20 NO-BOX.

        on help of v-chk in frame fr1 do:
            /* выбор ЧК */
            OPEN QUERY  q-book FOR EACH txb.checks where txb.checks.cif = txb.cif.cif no-lock.
            ENABLE ALL WITH FRAME f-book.
            wait-for return of frame f-book
            FOCUS b-book IN FRAME f-book.
            v-book = txb.checks.nono.

            find last txb.checks where txb.checks.nono = v-book no-lock no-error.
            if avail txb.checks then do:
                empty temp-table wrk-chk.
                do i = 1 to num-entries(txb.checks.pages, "|"):
                    create wrk-chk.
                    wrk-chk.chk = entry(i, txb.checks.pages, "|").
                end.
            end.

            /* выбор листа ЧК */
            OPEN QUERY  q-chk FOR EACH wrk-chk no-lock .
            ENABLE ALL WITH FRAME f-chk.
            wait-for return of frame f-chk
            FOCUS b-chk IN FRAME f-chk.
            if avail wrk-chk then v-chk = int(wrk-chk.chk).
            else v-chk = 0.

            hide frame f-chk.
            hide frame f-book.
            displ v-chk with frame fr1.
        end.
/*---------------------------------------------*/


v-chk = 0.
displ v-label v-label1 no-label with frame fr1.
update v-iik with frame fr1.
find first txb.aaa where txb.aaa.aaa = v-iik no-lock no-error.
  if not avail txb.aaa then do:
     message "Счет не найден ! " view-as alert-box.
     return.
  end.
  else do:
     v-crc = txb.aaa.crc.
     find txb.crc where txb.crc.crc = v-crc no-lock no-error.
     v-crc_val = txb.crc.code.
     find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
     if not avail txb.cif then do:
        message "Клиент не найден ! " view-as alert-box.
        return.
     end.
     if txb.cif.bin = '' then do: message v-bin view-as alert-box.
         if not v-bin then message ' ИИН/БИН отсутсвует в карточке клиента, запросите у клиента документ с ИИН/БИН и внесите данные в АБС. ' view-as alert-box title " ВНИМАНИЕ ! ".
         else do:
             message ' Операции без ИИН/БИН невозможны. ' view-as alert-box title " ВНИМАНИЕ ! ".
             return.
         end.
     end.

     if cif.crg = "" or cif.crg = ? then do:
        message "Счет " + txb.aaa.aaa + " заблокирован! Необходим акцепт для CIF " + txb.aaa.cif view-as alert-box.
        return.
     end.

     v-fio = txb.cif.name.
     if v-bin then v-rnn = txb.cif.bin. else v-rnn = txb.cif.jss.
     v-pss = txb.cif.pss.
     displ v-crc_val v-fio v-rnn v-pss with frame fr1.

     v-fu = txb.cif.type.
     if v-type ne '' and txb.cif.type = 'B' then v-comkod = '409,439,430,302'. /* снятие со счета юр лица*/

     if txb.aaa.cif ne v-cif-f then do:
        message "Счет принадлежит другому клиенту ! " view-as alert-box.
        return.
     end.
     if txb.aaa.sta = 'C' then do:
        message "Счет закрыт ! " view-as alert-box.
        return.
     end.
     if v-type ne '' then do:
        find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
        if lookup(txb.lgr.led, v-type) = 0 then do:
           message "Тип счета не " + v-type + " ! " view-as alert-box.
           return.
        end.
     end.

     /*********чеки**************/
     if txb.cif.type = 'B' or (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499) or (txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399) then do:
        repeat on endkey undo,return:
           update v-chk v-ser with frame fr1.
           v-ser = lower(v-ser).
           if lookup(substr(v-ser, 1 ,1),"q,a,z,w,s,x,e,d,c,r,f,v,t,g,b,y,h,n,u,j,m,i,k,l,o,p") <> 0 then do:
              message "Необходимо ввести серию русскими буквами"  view-as alert-box title "".  undo,retry.
           end.

           find first txb.gram where txb.gram.nono le v-chk and txb.gram.lidzno ge v-chk and txb.gram.ser <> "" and txb.gram.ser = v-ser and txb.gram.cif = txb.cif.cif no-lock no-error.
           if not available txb.gram then
                  find first txb.gram where txb.gram.nono le v-chk and txb.gram.lidzno ge v-chk and txb.gram.ser = ""  no-lock no-error.

               if not available txb.gram then do:
                   message "Чека с таким номером нет в системе.  Введите другой номер.".
                   undo, retry.
               end.
               if txb.gram.anuatz eq "*" then do:
                   message "Чековая книжка аннулирована.".
                   undo, retry.
               end.
               if txb.gram.cif eq "" then do:
                   message "Указанная чековая книжка еще не продана.".
                   undo, retry.
               end.

            find first txb.checks where txb.checks.nono <= v-chk and txb.checks.lidzno >= v-chk and txb.checks.cif = cif.cif and txb.checks.pages <> "" and checks.regdt > 09/25/12 no-lock no-error.
            if avail txb.checks then do:
                if index(txb.checks.pages, string(v-chk)) = 0 then do:
                    message "Данный чек уже использован" view-as alert-box.
                    undo, retry.
                end.
            end.

           if txb.gram.cif ne "" then do:
               if v-cif-f ne txb.gram.cif then do:
                   message "Чек клиенту не принадлежит".
                   undo, retry.
               end.
           end.
           leave.
        end.
     end.
     /***********************/


     update v-sum with frame fr1.
     v-fio1 = "".
     v-rnn1 = "".
     v-pss1 = "".

     def var fio as char.
     def var doc as char.
     def var rnn as char.

     if (txb.aaa.gl >= 220500 and txb.aaa.gl <= 220599)  then do:
         v-comkod = '302,429,419'.
         MESSAGE "Получатель является владелец счета?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE v-whplat.
         if v-whplat then do:
           v-fio1 = v-fio.
           v-rnn1 = v-rnn.
           v-pss1 = v-pss.
           /*displ  v-fio1 v-pss1 v-rnn1  with frame fr1.*/
         end. else do:
           update v-chr with frame fr3.
           if v-chr = 'u' or v-chr = 'U' or v-chr = 'Г' or v-chr = 'г' then do:
               find first txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday no-lock no-error.
               if avail txb.uplcif then do:
                   run seluplcif(output fio,output doc,output rnn).
                   v-fio1 = fio.
                   v-rnn1 = rnn.
                   v-pss1 = doc.
                   /*displ  v-fio1 v-pss1 v-rnn1  with frame fr1.*/
               end. else do:
                   message "У клиента нет уполномоченных лиц !" VIEW-AS ALERT-BOX TITLE "".
               end.
           end.
           if v-chr = 'n' or v-chr = 'N' or v-chr = 'Т' or v-chr = 'т' then do:
               find first txb.cif-heir where txb.cif-heir.cif = v-cif-f no-lock no-error.
               if avail txb.cif-heir then do:
                   run selcifref(output fio,output doc,output rnn).
                   v-fio1 = fio.
                   v-rnn1 = rnn.
                   v-pss1 = doc.
                   /*displ v-fio1 v-pss1 v-rnn1  with frame fr1.*/
               end. else do:
                   message "У клиента нет наследников !" VIEW-AS ALERT-BOX TITLE "".
               end.
           end.
         end.
     end.

     if (txb.aaa.gl >= 220400 and txb.aaa.gl <= 220499)  then do:
         v-comkod = '409,439,430'.
         MESSAGE "Получатель является владелец счета?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE v-whplat.
         if v-whplat then do:
           v-fio1 = v-fio.
           v-rnn1 = v-rnn.
           v-pss1 = v-pss.
         end. else do:
           update v-chr with frame fr4.
           if v-chr = 't' or v-chr = 'T' or v-chr = 'Е' or v-chr = 'е' then do:
              v-fio1 = "".
              v-rnn1 = "".
              v-pss1 = "".
           end.
           if v-chr = 'u' or v-chr = 'U' or v-chr = 'Г' or v-chr = 'г' then do:
               find first txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday no-lock no-error.
               if avail txb.uplcif then do:
                   run seluplcif(output fio,output doc,output rnn).
                   v-fio1 = fio.
                   v-rnn1 = rnn.
                   v-pss1 = doc.
               end. else do:
                   message "У клиента нет уполномоченных лиц !" VIEW-AS ALERT-BOX TITLE "".
               end.
           end.
         end.
     end.

     if (txb.aaa.gl >= 220300 and txb.aaa.gl <= 220399)  then do:
         v-comkod = '409,439,430'.
         def var v-yn as logical.
         v-yn = true.
         MESSAGE "Получатель является владелец счета?"  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE v-whplat.
         if v-whplat then do:
            update v-chr with frame fr5.
            if v-chr = 'u' or v-chr = 'U' or v-chr = 'Г' or v-chr = 'г' then do:
                find first txb.uplcif where txb.uplcif.cif = v-cif-f and txb.uplcif.coregdt <= v-gtoday and txb.uplcif.finday >= v-gtoday no-lock no-error.
                if avail txb.uplcif then do:
                    run seluplcif(output fio,output doc,output rnn).
                    v-fio1 = fio.
                    v-rnn1 = rnn.
                    v-pss1 = doc.
                end. else do:
                    message "У клиента нет уполномоченных лиц !" VIEW-AS ALERT-BOX TITLE "".
                end.
            end.
            if v-chr = 'r' or v-chr = 'R' or v-chr = 'К' or v-chr = 'к' then do:
               v-fio1 = "".
               v-rnn1 = "".
               v-pss1 = "".
               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchf" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-fio1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfrnn" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-rnn1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfdnum" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchfddt" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = v-pss1 + " " + txb.sub-cod.rcode.
            end.
            if v-chr = 'b' or v-chr = 'B' or v-chr = 'И' or v-chr = 'и' then do:
               v-fio1 = "".
               v-rnn1 = "".
               v-pss1 = "".
               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbk" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-fio1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkrnn" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-rnn1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbknum" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkdt" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = v-pss1 + " " + txb.sub-cod.rcode.

               find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnbkpl" and txb.sub-cod.acc = v-cif-f no-lock no-error.
               if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-pss1 = v-pss1 + " " + txb.sub-cod.rcode.
            end.
         end. else do:
           v-fio1 = "".
           v-rnn1 = "".
           v-pss1 = "".
         end.
     end.

     update  v-fio1 v-pss1 v-rnn1  with frame fr1.

     DEFINE QUERY q-tar FOR txb.tarif2.

     DEFINE BROWSE b-tar QUERY q-tar
            DISPLAY txb.tarif2.str5 label "Код тарифа " format "x(3)" txb.tarif2.pakalp label "Наименование   " format "x(40)"
            WITH  15 DOWN.
     DEFINE FRAME f-tar b-tar  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 85 NO-BOX.

     /*обработка F4*/

     on end-error of b-tar in frame f-tar do:
         hide frame f-tar.
        undo, return.
     end.

     on help of v-com in frame fr1 do:
         OPEN QUERY  q-tar FOR EACH txb.tarif2 where lookup (tarif2.str5, v-comkod)  > 0 no-lock.
         ENABLE ALL WITH FRAME f-tar.
         wait-for return of frame f-tar
         FOCUS b-tar IN FRAME f-tar.
         v-com = txb.tarif2.str5.
         hide frame f-tar.
         displ v-com with frame fr1.
     end.

     find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = v-cif-f no-lock no-error.
     if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-kbe = substring(txb.cif.geo, 3,1) + txb.sub-cod.ccode.

     update v-kod v-kbe v-knp v-com with frame fr1.

     /*find first txb.tarif2 where txb.tarif2.str5 = v-com and txb.tarif2.stat = 'r' no-lock no-error.
     if avail txb.tarif2 then do:
        v-sum_com = txb.tarif2.ost.
        if txb.tarif2.proc > 0 then do:
           v-sum_com = (v-sum / 100) * txb.tarif2.proc * txb.crc.rate[1].
           if txb.tarif2.min > 0 then do:
              if v-sum_com < txb.tarif2.min then v-sum_com = txb.tarif2.min.
           end.
        end.
        v-sum_com = v-sum_com / txb.crc.rate[1].
     end.*/

     /* вычисление суммы комиссии-----------------------------------*/
     run perev_txb (v-iik,input v-com, input v-sum, input v-crc, v-crc,v-cif-f, output v-amt, output tproc, output pakal).
     v-sum_com = v-amt.

     displ v-sum_com v-ja with frame fr1.

     if v-type ne '' then do:
        vavl = txb.aaa.cbal - txb.aaa.hbal.
        if txb.lgr.led = 'DDA' then do:
           find baaa where baaa.aaa = txb.aaa.craccnt no-lock no-error.
           if available baaa then vavl = vavl + baaa.cbal.
        end.

        if vavl < v-sum + v-sum_com then do:
           message "Нехватка средств на счете ! " view-as alert-box.
           return.
        end.
     end.

     update v-npl v-npl1 with frame fr1.
     find txb.sysc where txb.sysc.sysc = "bnkadr" no-lock no-error.
     if avail txb.sysc then do:
        v-mail = entry(5, txb.sysc.chval, "|") no-error.
     end.

     v-ja = no.
     update v-ja with frame fr1.
  end.


