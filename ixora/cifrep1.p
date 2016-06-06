/* cifrep1.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Отчет по общим доходам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        1.4.1.9.9
 * BASES
        BANK COMM
 * AUTHOR
        14.09.2010 k.gitalov
 * CHANGES
        31.04.2011 damir - добавил вывод курсового дохода. счет ГК 453010.
        30.04.2013 damir - Внедрено Т.З. № 1805.
*/

{global.i}

def var CurCat as char.
def buffer b-cif for cif.
def buffer b-aaa for aaa.
def buffer b-lgr for lgr.
def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var unknown as deci init 0.
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.
def var repname as char init "".
def var v-result as char init "".

define temp-table wrk no-undo
       field cif as char           /*Код клиента*/
       field trw as char           /*Категория клиента*/
       field comm-cred as deci decimals 2    /*Комиссии по выданным кредитам*/
       field supp-cred as deci decimals 2    /*% доход по кредитам*/
       field kass-oper as deci decimals 2    /*Кассовые операции*/
       field send-kz as deci decimals 2      /*Переводные операции в тенге*/
       field send-val as deci decimals 2     /*Переводные операции в ин.  валюте*/
       field conv-oper as deci decimals 2    /*Конвертация*/
       field doc-oper as deci decimals 2     /*Документарные операции*/
       field garan-oper as deci decimals 2   /*Гарантии*/
       field other-oper as deci decimals 2  /*Прочие комиссии*/
       field curs-doh as deci decimals 2.   /*Курсовой доход*/

define temp-table gl_wrk no-undo
            field type as int
            field gl as int
            field tarcod as char
            field name as char
            field crc as int.

/**************************************************************************************/
function LogFile returns integer (input p-file as char, input p-mess as char).
    output to value(p-file) append.
    put unformatted
        string(today,"99/99/9999") " "
        string(time, "hh:mm:ss") " "
        userid("bank") format "x(8)" " "
        p-mess skip.
    output close.
    return 0.
end function.
/**************************************************************************************/
function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.
/**************************************************************************************/
function DeleteFile returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("rm " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.
/**************************************************************************************/
function GetCatName returns char ( input code as char ):
    find first codfr where codfr.codfr = 'cifkat' and codfr.code = code no-lock no-error.
    if avail codfr then return codfr.name[1].
    else return 'ВСЕ'.
end function.
/**************************************************************************************/
function GetNormSumm returns char (input summ as deci ):
    def var ss1 as deci.
    def var ret as char.
    if summ >= 0 then do:
        ss1 = summ.
        ret = string(ss1,"->>>>>>>>>>>>>>>>9.99").
    end.
    else do:
        ss1 = - summ.
        ret = "-" + trim(string(ss1,"->>>>>>>>>>>>>>>>9.99")).
    end.
    return trim(ret).
end function.
/****************************************************************************************************************/
function GetDate returns char ( input dt as date):
    return replace(string(dt,"99/99/9999"),"/",".").
end function.
/**************************************************************************************/
function GetTypeCod returns int (input code as char ,input r-jh as int ):
    def buffer b-gl_wrk for gl_wrk.
    find first b-gl_wrk where b-gl_wrk.tarcod = trim(code) no-lock no-error.
    if avail b-gl_wrk then return b-gl_wrk.type.
    else do:
        LogFile("cifrep1.log","Не найден код тарифа " + code + " для проводки " + string(r-jh) ).
        return 0.
    end.
end function.
/**************************************************************************************/
function GetType returns int (input agl as int,input r-jh as int):
    def var curtype as int init -1.
    def buffer b-remtrz for remtrz.
    def buffer b-joudoc for joudoc.
    def buffer b-gl_wrk for gl_wrk.


    for each b-gl_wrk where b-gl_wrk.gl = agl no-lock:
        if curtype = -1 then curtype = b-gl_wrk.type.
        if curtype <> b-gl_wrk.type then do:  /*Неоднозначное определение группы комисии*/
            find first b-remtrz where  b-remtrz.valdt2 <= dt2 and b-remtrz.valdt2 >= dt1 and b-remtrz.jh1 = r-jh no-lock no-error.
            if avail b-remtrz then do:
                curtype = GetTypeCod ( string (b-remtrz.svccgr) , r-jh).
                if curtype = 0 then do:
                    LogFile("cifrep1.log","Найден RMZ " + b-remtrz.remtrz + "  проводка:" + string(r-jh) + " код комиссии:" + string (b-remtrz.svccgr)).
                end.
            end.
            else do:
                find first b-joudoc where  b-joudoc.whn >= dt1 and b-joudoc.whn <= dt2 and  b-joudoc.jh = r-jh no-lock no-error.
                if avail b-joudoc then do:
                    curtype = GetTypeCod ( string (b-joudoc.comcode) , r-jh).
                    if curtype = 0 then do:
                        LogFile("cifrep1.log","Найден JOU " + b-joudoc.docnum + "  проводка:" + string(r-jh) + " код комиссии - " + string (b-joudoc.comcode) ).
                    end.
                end.
            end.
            leave.
        end.
    end.
    /*if curtype = 6 or curtype = 7 then message "6/7" view-as alert-box. */
    return curtype.
end function.
/**************************************************************************************/
function Convcrc returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
 define buffer bcrc1 for crchis.
 define buffer bcrc2 for crchis.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.
end function.
/**************************************************************************************/
function GetSuppCred returns decimal ( input tcif as char ):
    def var summ as deci init 0.
    for each lon where lon.cif = tcif no-lock .
        for each lonres where lonres.jdt >= dt1 and lonres.jdt <= dt2 and lonres.lon = lon.lon and lonres.dc = 'c' and
        ( lonres.lev = 2 or lonres.lev = 16 ) no-lock:
            if lonres.crc = 1 then summ = summ + lonres.amt.
            else summ = summ + Convcrc(lonres.amt , lonres.crc , 1 , lonres.jdt ).
        end.
    end.
    return summ.
end function.
/**************************************************************************************/
function CreateRec returns int ( input cif as char , input acc as char ,
				                 output comm-cred  as deci ,
				                 output kass-oper  as deci ,
				                 output send-kz    as deci ,
				                 output send-val   as deci ,
				                 output conv-oper  as deci ,
				                 output doc-oper   as deci ,
				                 output garan-oper as deci ,
				                 output other-oper as deci):

    def buffer b-jl for jl.
    for each jl where jl.jdt >= dt1 and jl.jdt <= dt2 and jl.acc = acc and jl.dc = "D" /*jl.dam > 0*/ no-lock by jl.jh:
        find first jh where jh.jh = jl.jh and jh.party begins "Storn" no-lock no-error.
        if avail jh then next.
        find first b-jl where b-jl.jdt = jl.jdt and b-jl.jh = jl.jh and b-jl.dc = "C" and b-jl.ln = jl.ln + 1 no-lock no-error.
        if avail b-jl then do:
            case GetType(b-jl.gl,b-jl.jh):
                when -1 then do:
                /* г.к. не из нашего списка */
                next.
                end.
                when 0 then do:
                    /*Так и не нашли куда это отнести :(*/
                    LogFile("cifrep1.log","Невозможно определить группу для проводки "  + string(b-jl.jh) + " на сумму:" +  GetNormSumm( b-jl.cam )).
                    if b-jl.crc = 1 then unknown = unknown + b-jl.cam.
                    else unknown = unknown + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 1 then do: /*Комиссии по выданным кредитам*/
                    if b-jl.crc = 1 then comm-cred = comm-cred + b-jl.cam.
                    else comm-cred = comm-cred + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 2 then do: /*Кассовые операции*/
                    if b-jl.crc = 1 then kass-oper = kass-oper + b-jl.cam.
                    else kass-oper = kass-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 3 then do:  /*Переводные операции в тенге */
                    if b-jl.crc = 1 then send-kz = send-kz + b-jl.cam.
                    else send-kz = send-kz + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 4 then do:  /*Переводные операции в валюте */
                    if b-jl.crc = 1 then send-val = send-val + b-jl.cam.
                    else send-val = send-val + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 5 then do: /*Конвертация*/
                    if b-jl.crc = 1 then conv-oper = conv-oper + b-jl.cam.
                    else conv-oper = conv-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 6 then do: /*Документарные операции*/
                    if b-jl.crc = 1 then doc-oper = doc-oper + b-jl.cam.
                    else doc-oper = doc-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 7 then do: /*Гарантии*/
                    if b-jl.crc = 1 then garan-oper = garan-oper + b-jl.cam.
                    else garan-oper = garan-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
                when 8 then do: /*Прочие комиссии*/
                    if b-jl.crc = 1 then other-oper = other-oper + b-jl.cam.
                    else other-oper = other-oper + Convcrc(b-jl.cam , b-jl.crc , 1 , b-jl.jdt ).
                end.
            end case.
        end.
    end.
return 0.
end function.

/****************************************************************************************************************/
define frame fr
    skip(1)
    dt1  label 'C ' format '99/99/9999'
    dt2  label ' ПО' format '99/99/9999' skip
    with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА".

    dt1 = g-today. dt2 = g-today.

    update dt1 dt2 with frame fr.
    hide frame fr.
/**************************************************************************************/

if FileExist("cifrep1.log") then do:
   if not DeleteFile("cifrep1.log") then message "Ошибка при удалении временного файла." view-as alert-box.
end.

run LoadGL.

{comm-txb.i}

run catlist(0).
CurCat = return-value.
if CurCat = "EXIT" then return.

repname = "form1_" + comm-txb() + "_" + CurCat + "_" +   replace(string(dt1,"99/99/9999"),"/","-") + "_" +  replace(string(dt2,"99/99/9999"),"/","-") + ".html".


for each b-cif where b-cif.del = no /*and b-cif.cif = "O10803"*/ no-lock break by b-cif.trw by b-cif.cif:
    if CurCat <> "ALL" and b-cif.trw <> CurCat then next.

    for each b-aaa where b-aaa.cif = b-cif.cif and b-aaa.regdt <= dt2 /*and b-aaa.sta <> "E" and b-aaa.sta <> "C"*/ no-lock:
        find b-lgr where b-lgr.lgr = b-aaa.lgr and b-lgr.led <> "oda" no-lock no-error.
        if avail b-lgr then do:
            if b-aaa.sta = 'c' then do:
                find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = b-aaa.aaa and sub-cod.d-cod = 'clsa' no-lock no-error.
                if avail sub-cod then do:
                    if sub-cod.rdt < dt1 then next.
                end.
                else next.
            end.

            create wrk.
            wrk.cif = b-aaa.cif.
            wrk.trw = b-cif.trw.
            wrk.supp-cred = GetSuppCred( b-aaa.cif).
            CreateRec( wrk.cif , b-aaa.aaa ,
                          wrk.comm-cred ,
                          wrk.kass-oper ,
                          wrk.send-kz ,
                          wrk.send-val ,
                          wrk.conv-oper ,
                          wrk.doc-oper ,
                          wrk.garan-oper ,
                          wrk.other-oper ).

            curs-doh = 0.
            def buffer bjl for jl.
            for each jl where jl.sub = "cif" and jl.acc = b-aaa.aaa and jl.jdt >= dt1 and jl.jdt <= dt2 and jl.dc = "c" no-lock:
                find first bjl where bjl.jh = jl.jh and bjl.gl = 287044 no-lock no-error.
                if not avail bjl then next.
                find first bjl where bjl.jh = jl.jh and bjl.gl = 453010 no-lock no-error.
                if avail bjl then  do:
                    if bjl.crc = 1 then curs-doh = curs-doh + bjl.cam.
                    else curs-doh = curs-doh + Convcrc(bjl.cam , bjl.crc , 1 , bjl.jdt ).
                end.
            end.
            wrk.curs-doh = curs-doh.
        end.
        hide message no-pause.
        message "Сбор данных - " LN[i] " " b-aaa.cif.
        if i = 8 then i = 1.
        else i = i + 1.
    end. /*for each b-aaa*/
end. /*for each b-cif*/

hide message no-pause.

run ExportFile.

v-result = "".
input through value ("mv " + repname + " /data/reports/categ/" + repname ).
repeat:
    import unformatted v-result.
end.

if v-result <> "" then do:
    message " Произошла ошибка при копировании отчета - " v-result.
end.


if FileExist("cifrep1.log") then do:
    message "При формировании отчета произошли ошибки!~n Неопределенных платежей на сумму:" GetNormSumm( unknown ) view-as alert-box.
    LogFile("cifrep1.log","Неопределенных платежей на сумму:" + GetNormSumm( unknown ) ).
    unix silent cptwin cifrep1.log notepad.
end.

/***************************************************************************************************************/
procedure ExportFile.
    output to value(repname).
    {html-title.i}

    def var Caption as char init "Отчет по общим доходам".
    def var NameBank as char.
    def buffer b-cmp for cmp.
    find first b-cmp no-lock no-error.
    if avail b-cmp then do:
        NameBank = trim(b-cmp.name).
    end.

    put unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.

    put unformatted "<tr><td align=center colspan=10><font size=""4""><b><a name="" ""></a>" Caption "  " NameBank "  С " GetDate(dt1) " ПО " GetDate(dt2) "</b></font></td></tr>" skip.

    put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD>" "Категория" "</TD>" skip
                                "<TD>" "Комиссии по выданным кредитам" "</TD>" skip
                                "<TD>" "% доход по кредитам" "</TD>" skip
                                "<TD>" "Кассовые операции" "</TD>" skip
                                "<TD>" "Переводные операции в тенге" "</TD>" skip
                                "<TD>" "Переводные операции в ин.валюте" "</TD>" skip
                                "<TD>" "Конвертация" "</TD>" skip
                                "<TD>" "Курсовой доход" "</TD>" skip
                                "<TD>" "Документарные операции" "</TD>" skip
                                "<TD>" "Гарантии" "</TD>" skip
                                "<TD>" "Прочие комиссии" "</TD>" skip
                                "<TD>" "Итого" "</TD>" skip.

    def var comm-cred  as deci decimals 2 init 0.
    def var supp-cred  as deci decimals 2 init 0.
    def var kass-oper  as deci decimals 2 init 0.
    def var send-kz    as deci decimals 2 init 0.
    def var send-val   as deci decimals 2 init 0.
    def var conv-oper  as deci decimals 2 init 0.
    def var doc-oper   as deci decimals 2 init 0.
    def var garan-oper as deci decimals 2 init 0.
    def var other-oper as deci decimals 2 init 0.
    def var curs-doh   as deci decimals 2 init 0.


    def var comm-cred-all  as deci decimals 2 init 0.
    def var supp-cred-all  as deci decimals 2 init 0.
    def var kass-oper-all  as deci decimals 2 init 0.
    def var send-kz-all    as deci decimals 2 init 0.
    def var send-val-all   as deci decimals 2 init 0.
    def var conv-oper-all  as deci decimals 2 init 0.
    def var doc-oper-all   as deci decimals 2 init 0.
    def var garan-oper-all as deci decimals 2 init 0.
    def var other-oper-all as deci decimals 2 init 0.
    def var curs-doh-all   as deci decimals 2 init 0.

    def var all-all as deci decimals 2 init 0.

    for each wrk break by wrk.trw:
        if  LAST-OF(wrk.trw) then do:
            comm-cred = comm-cred + wrk.comm-cred.
            supp-cred = supp-cred + wrk.supp-cred.
            kass-oper = kass-oper + wrk.kass-oper.
            send-kz = send-kz + wrk.send-kz.
            send-val = send-val + wrk.send-val.
            conv-oper = conv-oper + wrk.conv-oper.
            doc-oper = doc-oper + wrk.doc-oper.
            garan-oper = garan-oper + wrk.garan-oper.
            other-oper = other-oper + wrk.other-oper.
            curs-doh = curs-doh + wrk.curs-doh.

            put unformatted "<TR style=""font-size:10pt"">" skip
                            "<TD>" GetCatName(wrk.trw) "</TD>" skip
                            "<TD>" GetNormSumm(comm-cred) "</TD>" skip
                            "<TD>" GetNormSumm(supp-cred) "</TD>" skip
                            "<TD>" GetNormSumm(kass-oper) "</TD>" skip
                            "<TD>" GetNormSumm(send-kz) "</TD>" skip
                            "<TD>" GetNormSumm(send-val) "</TD>" skip
                            "<TD>" GetNormSumm(conv-oper) "</TD>" skip
                            "<TD>" GetNormSumm(curs-doh) "</TD>" skip
                            "<TD>" GetNormSumm(doc-oper) "</TD>" skip
                            "<TD>" GetNormSumm(garan-oper) "</TD>" skip
                            "<TD>" GetNormSumm(other-oper) "</TD>" skip
                            "<TD>" GetNormSumm(comm-cred + supp-cred + kass-oper + send-kz + send-val + conv-oper + doc-oper + garan-oper + other-oper + curs-doh) "</TD>" skip.


            comm-cred-all = comm-cred-all + comm-cred.
            supp-cred-all = supp-cred-all + supp-cred.
            kass-oper-all = kass-oper-all + kass-oper.
            send-kz-all = send-kz-all + send-kz.
            send-val-all = send-val-all + send-val.
            conv-oper-all = conv-oper-all + conv-oper.
            doc-oper-all = doc-oper-all + doc-oper.
            garan-oper-all = garan-oper-all + garan-oper.
            other-oper-all = other-oper-all + other-oper.
            curs-doh-all = curs-doh-all + curs-doh.
            all-all = all-all + ( comm-cred + supp-cred + kass-oper + send-kz + send-val + conv-oper + doc-oper + garan-oper + other-oper + curs-doh).

            comm-cred = 0.
            supp-cred = 0.
            kass-oper = 0.
            send-kz = 0.
            send-val = 0.
            conv-oper = 0.
            doc-oper = 0.
            garan-oper = 0.
            other-oper = 0.
            curs-doh = 0.
        end.
        else do:
            comm-cred = comm-cred + wrk.comm-cred.
            supp-cred = supp-cred + wrk.supp-cred.
            kass-oper = kass-oper + wrk.kass-oper.
            send-kz = send-kz + wrk.send-kz.
            send-val = send-val + wrk.send-val.
            conv-oper = conv-oper + wrk.conv-oper.
            doc-oper = doc-oper + wrk.doc-oper.
            garan-oper = garan-oper + wrk.garan-oper.
            other-oper = other-oper + wrk.other-oper.
            curs-doh = curs-doh + wrk.curs-doh.
        end.
    end.

    put unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                                "<TD>" "Итого" "</TD>" skip
                                "<TD>" GetNormSumm(comm-cred-all) "</TD>" skip
                                "<TD>" GetNormSumm(supp-cred-all) "</TD>" skip
                                "<TD>" GetNormSumm(kass-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(send-kz-all) "</TD>" skip
                                "<TD>" GetNormSumm(send-val-all) "</TD>" skip
                                "<TD>" GetNormSumm(conv-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(curs-doh-all) "</TD>" skip
                                "<TD>" GetNormSumm(doc-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(garan-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(other-oper-all) "</TD>" skip
                                "<TD>" GetNormSumm(all-all) "</TD>" skip.

    put unformatted "</table>" .
    {html-end.i}
    output close.
    unix silent cptwin value(repname) iexplore.
    /*unix silent cptwin cifrep.html excel. */
end procedure.
/***************************************************************************************************************/

procedure LoadGL :
  empty temp-table gl_wrk.
  def buffer b-gl_wrk for gl_wrk.
  def var ktype as int.
  def var kpos as int.
  def buffer b-tarif2 for tarif2.
  def var TarCod as char extent 8 initial
                                 ["940,980,117,983,976,901,902,903,905,906,907,908,909,910", /* Комиссии по выданным кредитам*/
                                  "403,409,439,151,456,430,436,401,468,126,199", /*Кассовые операции */
                                  "214,215,163,019,017,202,222,111,112,147", /*Переводные операции в тенге*/
                                  "204,205,218,123,304,305,306", /*Переводные операции в ин.  валюте*/
                                  "804,802,808,803,809,810", /*Конвертация*/
                                  "970,995,996,971,997,998,999,910,972,960,961,962,963,964,965,966,967,968,969,952,953,954,955,956,957,958,959,941,942,943,944,945,946,947,911", /*Документарные операции*/
                                  "981,982,987,993,994,988,993,994,989,984,990,985,986", /*Гарантии*/
                                  "137,177,039,120,440,146,040,132,158,102,192,153,024,101,020,023,102,104,154,109,161,191"]. /*Прочие комиссии*/

    do ktype = 1 to 8:
        do kpos = 1 to NUM-ENTRIES(TarCod[ktype]):
            find first b-tarif2 where b-tarif2.num + b-tarif2.kod = trim(ENTRY(kpos,TarCod[ktype])) /* and b-tarif2.stat = 'r'*/ no-lock no-error.
            if avail b-tarif2 then do:
               create gl_wrk.
                      gl_wrk.type = ktype.
                      gl_wrk.gl = b-tarif2.kont.
                      gl_wrk.tarcod =  ENTRY(kpos,TarCod[ktype]).
                      gl_wrk.name = b-tarif2.pakalp.
                      find first gl where gl.gl = gl_wrk.gl no-lock no-error.
                      if avail gl then gl_wrk.crc = gl.crc.
            end.
            else do:
               message "Нет записей в тарификаторе с кодом " + ENTRY(kpos,TarCod[ktype]) + " !" view-as alert-box.
            end.
        end.
    end.

end procedure.