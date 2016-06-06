/* scan.p
 * MODULE
        Работа со сканером штрих-кодов
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
        5.3.16
 * AUTHOR
        23.08.2004 suchkov
 * BASES
        BANK
 * CHANGES
        18.07.2005 suchkov - исправил несколько ошибок
        05/10/2005 rundoll - добавил поле [28].
        02/10/2006 Ten     - добавил возможность проставления даты валютирования и срочности платежа
        19/03/2008 madiyar - переделал
        17/04/2008 madiyar - преобразование формата даты валютирования
        17/02/2010 madiyar - xml.i был сильно изменен для интернет-банкинга, старая версия i-шки используется здесь как xml_scan.i
*/

{mainhead.i}
{scan.i new}

{xml_scan.i}

def var xml_doc as handle.
create x-document xml_doc.
/*
def var v-xml as char no-undo.
def var m-xml as memptr.
*/
def var v-s as char no-undo.
def var v-l as logi no-undo.

define temp-table t-plat no-undo
    field tfld as character extent 28.

define variable i    as integer no-undo.
define variable vsum as character no-undo.

def stream outstr.

define query qcod for t-rmz.
define browse b1 query qcod
              displ
                 t-rmz.tfld[19] format "x(15)" label "Сумма"
                 t-rmz.tfld[1]  format "x(10)"  label "Номер"
                 t-rmz.rmz      format "x(10)" label "RMZ(Транз)"
                 t-rmz.terr     format "x(65)" label "Ошибки"
                 with 35 down no-box width 110.
define frame fcod b1 with no-box side-labels row 5 width 110.

def button b-scan label "Сканировать".
def button b-getdata label "Загрузить данные".
def button b-run label "Провести".

define frame top_buttons
  b-scan b-getdata b-run skip(1)
  with overlay no-labels no-box row 3.

define frame fpla
    t-rmz.tfld[1]  format "x(20)" label "Номер документа        "
    t-rmz.tfld[2]  format "x(20)" label "Дата документа" at 70 skip
    t-rmz.tfld[3]  format "x(80)" label "Отправитель            " skip
    t-rmz.tfld[4]  format "x(12)" label "РНН отправителя        "
    t-rmz.tfld[28] format "x(9)"  label "Приоритет     " at 70 skip
    t-rmz.tfld[5]  format "x(80)" label "Банк отправителя       " skip
    t-rmz.tfld[6]  format "x(20)" label "ИИК отправителя        " skip
    t-rmz.tfld[7]  format "x(20)" label "Код                    " skip
    t-rmz.tfld[8]  format "x(9)"  label "БИК банка отправителя  " skip
    t-rmz.tfld[9]  format "x(80)" label "Бенефициар             " skip
    t-rmz.tfld[10] format "x(12)" label "РНН бенефициара        " skip
    t-rmz.tfld[11] format "x(80)" label "Банк бенефициара       " skip
    t-rmz.tfld[12] format "x(20)" label "ИИК бенефициара        " skip
    t-rmz.tfld[13] format "x(20)" label "КБЕ                    " skip
    t-rmz.tfld[14] format "x(9)"  label "БИК банка бенефициара  " skip
    t-rmz.tfld[15] format "x(80)" label "Банк посредник         " skip
    t-rmz.tfld[16] format "x(12)" label "РНН банка посредника   " skip
    t-rmz.tfld[17] format "x(20)" label "ИИК посредника         " skip
    t-rmz.tfld[18] format "x(9)"  label "БИК посредника         " skip
    t-rmz.tfld[19] format "x(20)" label "Сумма                  " skip
    t-rmz.tfld[20] format "x(80)" label "Сумма прописью         " skip
    t-rmz.tfld[22] format "x(20)" label "Код назначения платежа " skip
    t-rmz.tfld[23] format "x(20)" label "КБК                    " skip
    t-rmz.tfld[24] format "x(20)" label "Дата валютирования     " skip
    t-rmz.tfld[25] format "x(80)" label "Назначение платежа     " skip
    t-rmz.tfld[26] format "x(80)" label "Директор (руководитель)" skip
    t-rmz.tfld[27] format "x(80)" label "Бухгалтер              " skip
    with overlay side-labels title "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ" row 5 width 110.


/* Обработчики */

on help of t-rmz.tfld[28] in frame fpla do:
   run uni_help1("urgency",'*').
end.

on choose of b-scan in frame top_buttons do:
    /*unix silent value("ssh Administrator@`askhost` start c:\\\scan\\\_ApiScan.bat").*/
    output stream outstr to run.cmd.
    put stream outstr unformatted "cd c:\\scan" skip "_ApiScan.bat" skip "exit" skip.
    output stream outstr close.
    unix silent value("scp -q run.cmd Administrator@`askhost`:c://tmp").
end.

on choose of b-getdata in frame top_buttons do:

    input through value("scp -q Administrator@`askhost`:c://scan//scanned.xml . ;echo $?").
    import unformatted v-s.
    input close.

    if v-s <> '0' then do:
        message v-s view-as alert-box error.
        undo,leave.
    end.

    unix silent value("echo >> ./scanned.xml"). /* на случай если нет возврата каретки в последней строке - добавляем */

    input through value("head -1 scanned.xml | //pragma//bin9//win2koi").
    import unformatted v-s.
    input close.

    if v-s matches "error*" then do:
        message v-s view-as alert-box error.
        undo,leave.
    end.

    v-l = xml_doc:load('file', "scanned.xml", no) no-error.
    if not v-l then do:
        message error-status:get-message(1) view-as alert-box error.
        undo,leave.
    end.

    unix silent value("ssh Administrator@`askhost` erase /F /Q c:\\\\scan\\\\scanned.xml").

    do transaction:
        create t-rmz.
        do i = 1 to 27:
            run get-node (xml_doc, "f" + string(i), output t-rmz.tfld[i]) no-error.
        end.

        /* преобразование формата даты валютирования */
        t-rmz.tfld[24] = trim(t-rmz.tfld[24]).
        if t-rmz.tfld[24] <> '' and length(t-rmz.tfld[24]) = 8 then do:
            t-rmz.tfld[24] = substring(t-rmz.tfld[24],7,2) + substring(t-rmz.tfld[24],5,2) + substring(t-rmz.tfld[24],1,4).
        end.

        display t-rmz.tfld[1]
                t-rmz.tfld[2]
                t-rmz.tfld[3]
                t-rmz.tfld[4]
                t-rmz.tfld[5]
                t-rmz.tfld[6]
                t-rmz.tfld[7]
                t-rmz.tfld[8]
                t-rmz.tfld[9]
                t-rmz.tfld[10]
                t-rmz.tfld[11]
                t-rmz.tfld[12]
                t-rmz.tfld[13]
                t-rmz.tfld[14]
                t-rmz.tfld[15]
                t-rmz.tfld[16]
                t-rmz.tfld[17]
                t-rmz.tfld[18]
                t-rmz.tfld[19]
                t-rmz.tfld[20]
                t-rmz.tfld[22]
                t-rmz.tfld[23]
                t-rmz.tfld[24]
                t-rmz.tfld[25]
                t-rmz.tfld[26]
                t-rmz.tfld[27]
                with frame fpla.

        t-rmz.sum = decimal (trim(replace(t-rmz.tfld[19],"-","."))) no-error.
        update t-rmz.tfld[28] t-rmz.tfld[24] with frame fpla.
    end. /* transaction */

    unix silent value("rm -f ./scanned.xml").

end.

on "end-error" of frame top_buttons return.

on "return" of browse b1
do:
    display t-rmz.tfld[1]
            t-rmz.tfld[2]
            t-rmz.tfld[3]
            t-rmz.tfld[4]
            t-rmz.tfld[5]
            t-rmz.tfld[6]
            t-rmz.tfld[7]
            t-rmz.tfld[8]
            t-rmz.tfld[9]
            t-rmz.tfld[10]
            t-rmz.tfld[11]
            t-rmz.tfld[12]
            t-rmz.tfld[13]
            t-rmz.tfld[14]
            t-rmz.tfld[15]
            t-rmz.tfld[16]
            t-rmz.tfld[17]
            t-rmz.tfld[18]
            t-rmz.tfld[19]
            t-rmz.tfld[20]
            t-rmz.tfld[22]
            t-rmz.tfld[23]
            t-rmz.tfld[24]
            t-rmz.tfld[25]
            t-rmz.tfld[26]
            t-rmz.tfld[27]
            t-rmz.tfld[28]
    with frame fpla.
    pause.
end.

/* Начало */

enable all with frame top_buttons.
view frame fpla.
wait-for choose of b-run in frame top_buttons.


/* run putjou.p . */
run putrmz.

open query qcod for each t-rmz no-lock by t-rmz.sum DESCENDING .
enable all with frame fcod.
wait-for window-close of frame fcod focus browse b1.

