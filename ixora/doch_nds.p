/* doch_nds.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Автоматизация операций по отражению начисленных расходов и оплаченного НДС
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
       8-12-3
 * AUTHOR
        18.01.2011 Luiza
        18.02.2011 Luiza добавила создание записи в dochhist
        22.02.2011 Изменили процедуру генерации номера документа
        26.04.11 Luiza в прцедуре create_doch : find current doch no-lock. заменила на find first doch no-lock.
        27.06.2011 Luiza запись даты today заменила на дату опер дня g-today doch.rdt = g-today
 * CHANGES

*/

{mainhead.i}

def var v-tmpl as char no-undo. /*шаблон проводки*/
def var vdel as char no-undo initial "^".
def var v-param as char no-undo. /*параметры для trxgen.p */
def var v-param1 as char no-undo. /* параметры для trxsim.p */
def var rcode as int no-undo.
def var rdes as char no-undo.
def new shared var v-select as integer no-undo.
def var v_title as char no-undo. /*наименование платежа */
def var v_sum as decimal no-undo. /* сумма расхода*/
def var v_rem as char no-undo format "x(20)".
def var v_arp as char format "x(20)" no-undo. /* счет  ARP*/
def var v_gl as int  no-undo. /* счет г/к  */
def var v_codfr as char format "x(1)" init "3". /*код операций  табл codfr для doch.codfr */

def var v_crc as int  no-undo.  /* Валюта*/
def var v_code as char  no-undo format "x(2)".  /* КОД*/
def var v_kbe as char  no-undo format "x(2)".  /* КБе*/
def var v_knp as char no-undo format "x(3)".  /* КНП*/
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v_ret as logi no-undo format "Да/Нет" init no.
def new shared var s-lon like lon.lon.
def new shared var v-num as integer no-undo.
def var vparr as char no-undo.
def new shared var v-docid1 as char format "x(19)" no-undo.
def new shared var v-docid as char format "x(9)" no-undo.
def var v-rdt as date no-undo.
def var v-rtim as int no-undo.
def var s-acc as char no-undo.
def var v_list as char no-undo.

define temp-table glhelp like gl.
 for each gl where gl.gl >= 560800 and gl.gl <= 592399 and gl.crc = 1 no-lock:
    create glhelp.
    buffer-copy gl to glhelp.
end.

define button b1 label "НОВЫЙ".
define button b2 label "НА КОНТРОЛЬ".
define button b3 label "ТРАНЗАКЦИЯ".
define button b4 label "ОРДЕР".
define button b5 label "УДАЛИТЬ".
define button b6 label "ПРОСМОТР".
define button b7 label "ВЫХОД".

define frame a2
    b1 b2 b3 b4 b5 b6 b7
    with side-labels row 4 column 5 no-box.

   form
        v-docid label " Документ " format "x(9)" skip(1)
        v_sum LABEL " Сумма" format ">>>,>>>,>>>,>>>,>>9.99" skip
        v_gl label " Счет Дт г/к" format "zzzzzz" skip
        v_arp label " Счет Кт ARP" format "X(20)" skip
        v_rem label " Назначение платежа" format "X(40)" skip(1)
        v-ja label " Отправить на контроль?..........."   skip
        WITH  SIDE-LABELS  ROW 7 column 10
    TITLE v_title width 70 FRAME Frame1.

     Form
        v-docid label " Документ " format "x(9)" skip(1)
        v_sum LABEL " Сумма" format ">>>,>>>,>>>,>>>,>>9.99" validate(v_sum > 0,"Проверьте значение суммы!") skip
        v_gl label " Счет Дт г/к" format "zzzzzz"  validate(can-find(first glhelp where glhelp.gl = v_gl and
                            lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock),"Неверный счет Г/К!")  skip
        v_arp label " Счет Кт ARP" format "X(20)" skip
        v_rem label " Назначение платежа" format "X(40)"  help "Введите текст примечания; F4-выход" skip(1)
        v-ja label " Отправить на контроль?..........."   skip
        WITH  SIDE-LABELS  ROW 7 column 10
    TITLE v_title width 70 FRAME Frame2.

/*frame for help GL*/
DEFINE QUERY q-glhelp FOR glhelp.

DEFINE BROWSE b-glhelp QUERY q-glhelp
       DISPLAY glhelp.gl label "Счет Г/К " format "999999" glhelp.sname label "Наименование     " format "x(30)"
       glhelp.crc label "Вл." format "z9"
       WITH  15 DOWN.
DEFINE FRAME f-glhelp   b-glhelp  WITH overlay 1 COLUMN SIDE-LABELS row 11 COLUMN 40 width 69 NO-BOX.

on end-error of b-glhelp in frame f-glhelp do:
    hide frame f-glhelp.
   undo, return.
end.

on help of v_gl in frame frame2 do:
    run proc_glhelp (v_list, output v_gl).
    displ v_gl with frame frame2.
end.


/*выбор кнопки новый*/
on choose of b1 in frame a2 do:
 v-select = 0.
 hide frame frame1.
 hide frame frame2.
  run sel2 (" ВИДЫ  ОПЕРАЦИЙ ", " 1. НДС НА РАСХОДЫ | 2. НАЧИСЛЕННЫЕ РАСХОДЫ | 3. Выход ", output v-select).
        if v-select = 0 then return.
        v-docid = "".
        run dochgen (output v-docid).
         if v-docid = "" then do:
            message "Ошибка генерации номера документа. Обратитесь к администратору.".
            pause.
            hide message.
            return.
        end.
        v_code = "14".
        v_kbe = "14".
        v_knp = "840".
        case v-select:

        when 1 then do:
            v_list = "январь,февраль,март,апрель,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".
            v_sum = 0.
            v_crc = 1.
            v_gl = 576100.
            v_arp = "".
            run varp1 (output v_arp).
            if v_arp = "" then do:
                message "Ошибка кода филиала. Обратитесь к администратору.".
                pause.
                hide message.
                return.
            end.
            find first trxbal where trxbal.subled = "arp" and trxbal.acc = v_arp no-lock no-error.
            if not available trxbal then do:
               message "Не найден остаток по счету arp " + v_arp + ". Обратитесь к администратору.".
               pause.
               hide message.
               return.
            end.
            if trxbal.level = 1 then v_sum = trxbal.dam - trxbal.cam.
            else v_sum = trxbal.cam - trxbal.dam.
            v_rem = "НДС оплаченный за " + entry(month(today),v_list) + " " + string(year(today)) + "г.".
            v_title = " НДС НА РАСХОДЫ ".
            v-tmpl = "uni0004".
            v_ret = yes.
            v-ja = no.
            displ v-docid v_sum v_gl v_arp v_rem v-ja with  frame frame1.
            do while v_ret:
                v_ret = no.
                update v-ja  with frame frame1.
                 /* формир v-param для trxgen.p */
                v-param = string(v_sum) + vdel + string(v_crc) + vdel + string(v_gl) + vdel + v_arp + vdel + v_rem +
                        vdel + "1" + vdel + "4" + vdel + v_knp.

                /* формир v-param1 для trxsim.p */
                v-param1 = string(v_sum) + vdel + string(v_crc) + vdel + string(v_gl) + vdel + v_arp + vdel + v_rem.
                run create_doch.
                if rcode <> 0 then v_ret = yes.
            end. /* end do while v_ret*/
        end. /* end when 1  */
/*---------------*/
        when 2 then do:
            v_list = "5608,5741,5742,574,5744,5745,5746,5748,5749,5750,5752,5753,5921,5922,5923".
            v_sum = 0.
            v_crc = 1.
            v_arp = "".
            run varp2 (output v_arp).
            if v_arp = "" then do:
                message "Ошибка кода филиала. Обратитесь к администратору.".
                pause.
                hide message.
                return.
            end.
            v_rem = "".
            v_gl = 0.
            v_title = " НАЧИСЛЕННЫЕ РАСХОДЫ".
            v-tmpl = "uni0004".
            v_ret = yes.
            v-ja = no.
            displ v-docid  v_arp v-ja with  frame frame2.
            do while v_ret:
                v_ret = no.
                update v_sum help " Введите сумму; F4-выход" v_gl  help "Введите счет дебета г/к; F2-помощь; F4-выход"  v_rem with frame frame2.
                update v-ja  with frame frame2.
                 /* формир v-param для trxgen.p */
                v-param = string(v_sum) + vdel + string(v_crc) + vdel + string(v_gl) + vdel + v_arp + vdel + v_rem +
                            vdel + "1" + vdel + "4" + vdel + v_knp.
                /* формир v-param1 для trxsim.p */
                v-param1 = string(v_sum) + vdel + string(v_crc) + vdel + string(v_gl) + vdel + v_arp + vdel + v_rem.
                run create_doch.
                if rcode <> 0 then v_ret = yes.
            end. /*end do while v_ret:*/
        end.
     when 3 then return.
   end case.

 hide frame frame1.
 hide frame frame2.
end. /*конец кнопки новый*/

on choose of b2 in frame a2 do: /* кнопка контроль*/
run doch_control (v_codfr).
end. /*конец кнопки контроль*/

on choose of b3 in frame a2 do: /* кнопка транзакция*/
run doch_trx (v_codfr).
end. /*конец кнопки транзакция*/

on choose of b4 in frame a2 do: /* кнопка ордер(к)*/
run doch_order (v_codfr).
end. /*конец кнопки ордер(к)*/

on choose of b5 in frame a2 do: /* кнопка del*/
run doch_del (v_codfr).
end. /*конец кнопки del*/

on choose of b6 in frame a2 do: /* кнопка просмотр*/
run doch_view (v_codfr).
end. /*конец кнопки просмотр**/

on choose of b7 in frame a2 do:
    hide frame a2.
    return.
end. /*конец кнопки выход*/

    enable all with frame a2.
    wait-for window-close of frame a2 or choose of b7 in frame a2.



procedure dochgen. /*генерация номера след документа */
    def output parameter v-docid as char format "x(9)".
    def var num1 as int.
    find first nmbr where nmbr.code = "JOU" no-lock no-error.
    do transaction:
        num1 = NEXT-VALUE(dochnum).
        v-docid = "D" + string(num1, "9999999") + caps(nmbr.prefix).
    end.
end procedure.

procedure proc_glhelp.
def input parameter v_list as char.
def output parameter v_gl1 as int.
find first glhelp where lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock no-error.
    if available glhelp then do:
        OPEN QUERY  q-glhelp FOR EACH glhelp where lookup(substring(string(glhelp.gl),1,4),v_list) > 0 no-lock.
        ENABLE ALL WITH FRAME f-glhelp.
        wait-for return of frame f-glhelp
        FOCUS b-glhelp IN FRAME f-glhelp.
        v_gl1 = glhelp.gl.
        hide frame f-glhelp.
   end.
    else do:
        MESSAGE "СЧЕТ Г/Л РАСХОДЫ НЕ НАЙДЕН.".
        v_gl1 = 0.
    end.
end procedure.

procedure varp1.
    def output parameter v_arp1 as char.
    def var s-ourbank as char no-undo.
    find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
    if not avail sysc or sysc.chval = "" then do:
       display " There is no record OURBNK in bank.sysc file !!".
       pause.
       return.
    end.
    s-ourbank = trim(sysc.chval).
    case s-ourbank:
        when "TXB00" then v_arp1 = "KZ93470111851A006800".
        when "TXB16" then v_arp1 = "KZ73470111851A002116".
        when "TXB01" then v_arp1 = "KZ11470111851A001001".
        when "TXB02" then v_arp1 = "KZ63470111851A002102".
        when "TXB04" then v_arp1 = "KZ90470111851A002004".
        when "TXB03" then v_arp1 = "KZ69470111851A001703".
        when "TXB05" then v_arp1 = "KZ63470111851A002005".
        when "TXB06" then v_arp1 = "KZ04470111851A001806".
        when "TXB07" then v_arp1 = "KZ90470111851A001907".
        when "TXB08" then v_arp1 = "KZ32470111851A001108".
        when "TXB09" then v_arp1 = "KZ20470111851A001809".
        when "TXB10" then v_arp1 = "KZ74470111851A001710".
        when "TXB11" then v_arp1 = "KZ14470111851A002111".
        when "TXB12" then v_arp1 = "KZ68470111851A002012".
        when "TXB13" then v_arp1 = "KZ41470111851A002013".
        when "TXB14" then v_arp1 = "KZ30470111851A002114".
        when "TXB15" then v_arp1 = "KZ84470111851A002015".
    end case.
end procedure.

procedure varp2.
    def output parameter v_arp1 as char.
    def var s-ourbank as char no-undo.
    find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
    if not avail sysc or sysc.chval = "" then do:
       display " There is no record OURBNK in bank.sysc file !!".
       pause.
       return.
    end.
    s-ourbank = trim(sysc.chval).
    case s-ourbank:
        when "TXB00" then v_arp1 = "KZ57470142867A025300".
        when "TXB16" then v_arp1 = "KZ06470142867A010116".
        when "TXB01" then v_arp1 = "KZ38470142867A010801".
        when "TXB02" then v_arp1 = "KZ12470142867A010202".
        when "TXB04" then v_arp1 = "KZ08470142867A009304".
        when "TXB03" then v_arp1 = "KZ52470142867A008803".
        when "TXB05" then v_arp1 = "KZ28470142867A010205".
        when "TXB06" then v_arp1 = "KZ19470142867A009106".
        when "TXB07" then v_arp1 = "KZ23470142867A009907".
        when "TXB08" then v_arp1 = "KZ75470142867A011008".
        when "TXB09" then v_arp1 = "KZ66470142867A009909".
        when "TXB10" then v_arp1 = "KZ23470142867A009810".
        when "TXB11" then v_arp1 = "KZ93470142867A009811".
        when "TXB12" then v_arp1 = "KZ66470142867A009812".
        when "TXB13" then v_arp1 = "KZ39470142867A009813".
        when "TXB14" then v_arp1 = "KZ92470142867A010314".
        when "TXB15" then v_arp1 = "KZ98470142867A009915".
    end case.
end procedure.

procedure create_doch:
    do transaction:
        create doch.
        doch.docid = v-docid.
        doch.rdt = g-today.
        doch.rtim = TIME.
        doch.rwho = g-ofc.
        if v-ja then  doch.sts = "sen".
        else doch.sts = "new".
        doch.templ = v-tmpl.
        doch.delim = vdel.
        doch.param1 = v-param.
        doch.sub = "arp".
        doch.acc = v_arp.
        doch.codfr =  v_codfr.
        v-docid1 = v-docid + "," + v_code + "," + v_kbe + "," + v_knp.
        v-rdt =  doch.rdt.
        v-rtim = doch.rtim.
        find first doch no-lock.
        run trxsim (v-docid1, v-tmpl, vdel, v-param1, 1, output rcode, output rdes, output vparr).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            undo.
            next.
        end.
        run doch_hist (v-docid).
      if v-ja then run pr_doch_order(v-docid, v-rdt, v-rtim, g-ofc).
     /* оконч формир проводки в doch и docl */
     end. /*end trans-n*/
end procedure.

