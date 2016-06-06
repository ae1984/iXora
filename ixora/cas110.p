/* cas110.p
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Работа с хранилищем
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню 4-2-15
 * AUTHOR
        28/12/2010 marina
 * BASES
        BANK
 * CHANGES
        20.01.2011 marinav добавлено заявление на аванс
        18.05.2011 aigul - исправила состояние кассы, при удалении проводки
        07.03.2012 damir - добавил новые форматы, trxsts.
        11.03.2012 damir - изменения в новых форматах.
        04/05/2012 evseev - изменил путь к логотипу
*/

{mainhead.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def var v-deb like gl.gl no-undo.
def var v-cre like gl.gl no-undo.

def var v-tmpl as char no-undo.

def var v-sum as deci no-undo.
def var v-crc like crc.crc.
def var v-crc_val as char no-undo format "xxx".
def var v-kod as char no-undo init "14".
def var v-kbe as char no-undo init "14".
def var v-knp as char no-undo init "890".
def var v-tit as char.
def var v-rem as char no-undo .
define variable sumstr as character.
def var russ as char extent 12 NO-UNDO
                init ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"].

def var v-ja as logi no-undo format "Да/Нет" init no.

def new shared var s-jh like jh.jh.
def var v-glrem as char no-undo.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def var v-sel as char init '0'.
run sel2 ("Операция :", " 1. Выдача денежной наличности из хранилища  | 2. Прием денежной наличности в хранилище | 3. Удаление проводки ", output v-sel).
if v-sel = '0' then return.
if v-sel = '1' then assign v-deb = 100100 v-cre = 100110 v-tit = 'Выдача денежной наличности из хранилища'.
if v-sel = '2' then assign v-deb = 100110 v-cre = 100100 v-tit = 'Прием денежной наличности в хранилище'.

if v-sel = '3' then do:
    def var sure as log init false.
    def var v-jh like jh.jh.
    def var v-sts like jh.sts.

    displ " Режим удаления / сторнирования транзакций " with centered row 5
    frame sss.

    update v-jh label "Транзакция" with centered side-label frame vvv .
    find jh where jh.jh eq v-jh no-lock no-error.
    find first jl where jl.jh = jh.jh no-error .

    if not avail jl then do:
       message " Транзакция не найдена " .
       return.
    end.

    do transaction on error undo, retry:

        if jh.jdt lt g-today then do:
            message " Транзакция не текущего дня. Удаление невозможно!".
            undo, return.
        end.
        if  lookup(jl.trx,"uni0204,uni0205") = 0 then do:
            message " В этом пункте удаляются только операции по счету 100110 !".
            undo, return.
        end.

        message "Вы уверены ?" update sure.
        if not sure then undo, return.

        find sysc where sysc.sysc = 'CASHGL' no-lock.
        /*for each jl where jl.jh = v-jh:*/
        find first jl where jl.jh = v-jh no-lock no-error.
        if avail jl then do:
            if jl.gl = sysc.inval and jl.sts = 6 then  do:
                /*
                find first cashofc where cashofc.whn eq g-today and cashofc.crc eq jl.crc and cashofc.sts eq 2 and cashofc.ofc eq jl.who no-error.
                    if avail cashofc then  cashofc.amt = cashofc.amt + jl.dam + jl.cam.
                    else do:
                       create cashofc.
                       cashofc.who = g-ofc.
                       cashofc.ofc = g-ofc.
                       cashofc.whn = g-today.
                       cashofc.crc = jl.crc.
                       cashofc.sts = 2.
                       cashofc.amt = jl.cam - jl.dam.
                    end.*/
                /*aigul*/
                find first trxdel_aks_control where trxdel_aks_control.jh = jl.jh no-lock no-error.
                if avail trxdel_aks_control and trxdel_aks_control.sts = "a" then do:
                    find first cashofc where cashofc.whn eq g-today and cashofc.crc eq jl.crc and cashofc.sts eq 2 and cashofc.ofc eq jl.who no-error.
                    if avail cashofc then  cashofc.amt = cashofc.amt + jl.dam + jl.cam.
                    else do:
                       create cashofc.
                       cashofc.who = g-ofc.
                       cashofc.ofc = g-ofc.
                       cashofc.whn = g-today.
                       cashofc.crc = jl.crc.
                       cashofc.sts = 2.
                       cashofc.amt = jl.cam - jl.dam.
                    end.
                end.
                if not avail trxdel_aks_control then do:
                   find first cashofc where cashofc.whn eq g-today and cashofc.crc eq jl.crc and cashofc.sts eq 2 and cashofc.ofc eq jl.who no-error.
                    if avail cashofc then  cashofc.amt = cashofc.amt - jl.dam + jl.cam.
                    else do:
                       create cashofc.
                       cashofc.who = g-ofc.
                       cashofc.ofc = g-ofc.
                       cashofc.whn = g-today.
                       cashofc.crc = jl.crc.
                       cashofc.sts = 2.
                       cashofc.amt = jl.cam - jl.dam.
                    end.
                end.
                /**/
            end.
            v-sts = jh.sts.
            run trxsts (input v-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.
            run trxdel (input v-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                if rcode = 50 then do:
                   run trxsts (input v-jh, input v-sts, output rcode, output rdes).
                   return.
                end.
                else undo, return.
            end.

        end.
    end.
    return.
end.



form  skip(1)
    v-deb label "Дебет          " skip
    v-cre label "Кредит         " skip
    v-sum label "Сумма          " format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-crc label "Валюта         "  help "F2 - справочник" v-crc_val no-label skip
    v-rem label "Примечание     " format "x(60)" skip
    v-kod label "Код            " format "x(2)" skip
    v-kbe label "Кбе            " format "x(2)" skip
    v-knp label "КНП            " format "x(3)" skip(1)
    v-ja label "Формировать транзакцию?   " skip(1)
with centered side-label row 7 width 80 overlay  title v-tit frame fr1.


  displ v-deb v-cre v-kod v-kbe v-knp v-ja with frame fr1.
  update v-sum v-crc v-rem with frame fr1.

  find first crc where crc.crc = v-crc no-lock no-error.
  if avail crc then v-crc_val = crc.code.
  else do:
    message "Ошибка определения валюты кредита" view-as alert-box error.
    return.
  end.

  displ v-crc_val with frame fr1.

  v-ja = no.
  update v-ja with frame fr1.

/*********************************************************************/

  if v-ja then do:

           if v-sel = '1' then v-tmpl = "uni0204".
           if v-sel = '2' then v-tmpl = "uni0205".
           v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-rem.

           s-jh = 0.
           run trxgen (v-tmpl, vdel, v-param, "", "" , output rcode, output rdes, input-output s-jh).
                   if rcode ne 0 then do:
                           message rdes.  pause 1000.  next.
                   end.
                   run trxsts (input s-jh, input 6, output rcode, output rdes).
                   /*find first jh where jh.jh = s-jh exclusive-lock.
                   jh.sts = 6.
                   for each jl of jh:
                         jl.sts = 6.
                         jl.teller = g-ofc.
                   end.*/
                   /*jh.sub = 'ujo'.*/
                   find current jh no-lock no-error.
                  /* if v-sel = '1' then  run setcsymb (s-jh, 200).
                   if v-sel = '2' then  run setcsymb (s-jh, 500).
                    */
                   if v-noord = no then run uvou_bank ("prit").
                   else run printord(s-jh,v-sel).

                   if v-sel = '1' then do:

                       message "Печатать заявление?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "" UPDATE choice AS LOGICAL.

                       if choice = yes then do:
                             output to rpt.html.
                             {html-start.i}

                             run Sm-vrd(v-sum, output sumstr).

                             find crc where crc.crc = v-crc no-lock no-error.

                             put unformatted "<img src=""c://tmp/top_logo_bw.jpg"" width=""250"" height=""25""><br>" skip.
                             put unformatted "<div align=""right"">" skip.
                             put unformatted "Разрешаю выдать &nbsp;&nbsp; <B>" REPLACE (STRING(v-sum, "z,zzz,zzz,zz9"), ",", " ") "</B> &nbsp; "  CAPS(crc.code) " <BR>" skip.
                             put unformatted "Директор филиала <BR>" skip.
                             put unformatted "_____________________<BR>" skip.
                             put unformatted "Подпись &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<BR>" skip.
                             put unformatted "&laquo;" DAY (TODAY) "&raquo; &nbsp;&nbsp;" russ[MONTH(TODAY)] "&nbsp; " YEAR(TODAY) " г.<BR>" skip.
                             put unformatted "</div>" skip.
                             put unformatted "<H1 align=""center"">Заявление</H1>" skip.
                             put unformatted "<H4>Прошу разрешить выдачу аванса на расходы:</H4>" skip.
                             put unformatted "<H4>Для кассовых операций</H4>" skip.
                             put unformatted "<H4>Итого: " sumstr " "  (crc.des) " </H4>" skip.
                             put unformatted "<H4>Дата получения аванса " g-today " г." skip.
                             put unformatted "<div align=""right""><BR>" skip.
                             put unformatted "___________________________________<BR>" skip.
                             put unformatted "Фамилия,  имя,  отчество.  Подпись <BR>" skip.
                             put unformatted "</div>" skip.
                             put unformatted "<div align=""right""><BR>" skip.
                             put unformatted "<H4>&laquo; " DAY (TODAY) "&raquo; &nbsp;&nbsp;" russ[MONTH(TODAY)] "&nbsp; " YEAR(TODAY) " г.</H4>" skip.

                             {html-end.i}

                             output close.
                             unix silent cptwin rpt.html winword.
                       end.
                   end.

  end.
