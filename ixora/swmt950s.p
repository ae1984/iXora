/* swmt950s.p
 * MODULE
        Выписки по счетам клиентов в формате МТ950
 * DESCRIPTION
        Основной формат печати выписки
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR

 * BASES
        BANK COMM
 * CHANGES

            18/04/2012 Luiza
            07/05/2012 Luiza  -  изменила бик банка
*/


{comm-txb.i}

define input parameter destination as character.
define input parameter vv-acc like aaa.aaa.        /* Customer's Account         */
define input parameter vv-dt   as date.        /* Period Begin                */
define shared var g-lang as char.
define shared var g-fname like nmenu.fname.
def var vdet as char.

def var vatf as char.
def var vkartel as char.

def var tmpval as char.
define var seltxb as int.
seltxb = comm-cod().

/* -------  Новая переменная --- индикатор счета (валюта или теньге) */
/* -------  Если в валюте, то VAL_ACC = YES иначе NO -----*/
def variable fun2_4_2  as logical init no.
def variable val_acc   as logical init yes.
def variable val_peres as decimal decimals 10 format "->>,>>>,>>>,>>>,>>9.99".
def variable val_from  like crc.rate[1].
def variable val_to    like crc.rate[1].
def var val_kind as integer format "9" init 1. /* 1 - пересчет по средневзвеш.курсу, 2 - по нацбанку */

def variable numline as integer init 1.
def variable prevjou as char init "".
def variable i as integer.

/* Temporary Tables Structure Defining --------------------------------- */

{header-t.i "shared" }
{deals.i    "shared" }

define variable crccode as character.
define variable crccode20 as character no-undo.

define variable v-kurs as decimal.                  /* --- Currency Kurs     */
define variable v-koef as integer.                  /* --- Currency Quantity */
define variable lines as integer initial 0.         /* --- Lines in deal          */

define variable d_t as decimal initial 0.
define variable c_t as decimal initial 0.

define variable ordins         as character extent 4.
define variable ordcust  as character extent 4.
define variable ordacc         as character.
define variable benfsr   as character extent 4.
define variable benbank  as character extent 4.
define variable benacc   as character .
define variable dealsdet as character extent 4.
define variable bankinfo as character extent 4.

define variable itogo_c as decimal init 0.
define variable itogo_d as decimal init 0.
define variable t-amt as decimal init 0.
def var v-aaa20 as char no-undo.


{stlib.i}
{r-htrx2.f}

function getcrc returns char(cc as int).
    find first crc where crc.crc = cc no-lock no-error.
    if avail crc then return crc.code.
    else return "".
end.

function rus-eng2 returns char (str2 as char).
    define var outstr2 as char.
    def var rus2 as char extent 32 init
    ["А","Б","В","Г","Д","Е", "Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф", "Х","Ц", "Ч", "Ш", "Щ", "Ъ","Ы", "Ь", "Э", "Ю", "Я"].
    def var eng2 as char  extent 32 init
    ["A","B","V","G","D","E","ZH","Z","I","J","K","L","M","N","O","P","R","S","T","U","F","KH","C","CH","SH","SCH","","Y","","E","YU","YA"].

    def var i2 as integer.
    def var j2 as integer.
    def var ns2 as log init false.
    def var slen2 as int.
    str2 = caps(str2).
    slen2 = length(str2).

    repeat i2 = 1 to slen2:
     repeat j2 = 1 to 32:
       if substr(str2,i2,1) = rus2[j2] then
       do:
          outstr2 = outstr2 + eng2[j2].
          ns2 = true.
       end.
     end.
     if not ns2 then outstr2 = outstr2 + substr(str2,i2,1).
     ns2 = false.
    end.
    return outstr2.
end.

    define variable v-bic as char.
    def var ValData as char.
    def var ValData1 as char.
    def var vh-amt as decim.
    def var v-dc as char.
    def var v-len as char.
    def var vv-crc as int.
    def var vv-code as char.
    def var v_sum1 as decim.
    def var v-lastdt as date.
    def var v-seq as int.
    form
        v-bic label "Бик банка" format "x(11)" validate(v-bic <> "", "Некорректный Бик!") skip
    with side-label row 10 frame f1.
    update v-bic with frame f1.
    find first acc_list no-lock.
    v-seq = acc_list.seq.
    if v-seq - 2 > 0 then v-seq = v-seq - 2.
    find last jl where jl.jdt < vv-dt and jl.acc = vv-acc use-index jdtaccgl no-lock no-error.
    if available jl then v-lastdt = jl.jdt.
    else v-lastdt = vv-dt.
        find first deals where deals.servcode = "ob" no-error.

        ValData = '\{1:F01FOBAKZKAAXXXXXXXXXXXXX}\{2:I950' + caps(trim(v-bic)) + 'XXXXN}'.
        ValData = ValData + "\{4:\r\n".
        ValData = ValData + ":20:" + substring(string(year(deals.d_date + 1)),3,2) + string(month(deals.d_date + 1),"99") +
            string(day(deals.d_date + 1),"99") + "FOBAK" + trim(string(v-seq,"zzz9999")) /*string(month(today),"99") + string(day(today),"99")*/ + "\r\n".

        ValData = ValData + ":25:" + deals.account + "\r\n".
        ValData = ValData + ":28C:" + trim(string(v-seq,"zzz9999")) /*string(month(today),"99") + string(day(today),"99")*/ + "/1" + "\r\n".
        if deals.amount >= 0 then v-dc = "C". else v-dc = "D".
        ValData = ValData + ":60F:" + v-dc + substring(string(year(v-lastdt)),3,2) + string(month(v-lastdt),"99") + string(day(v-lastdt),"99") +
                            getcrc(deals.crc) + replace(trim(string(deals.amount)),'.',',') + "\r\n".
        for each deals where  deals.servcode = "lt" or deals.servcode = "st" .
            vv-code  = "".
            /*if deals.TRXCode = "TRF" then vv-code = "STRF".*/
            if deals.TRXCode = "chg" then  vv-code = "NCHG".
            else vv-code = "STRF".
                v_sum1 = decim(entry(1,string(deals.amount),".")).
                if ((v_sum1 - decim(entry(1,string(v_sum1),".")))) + (deals.amount - decim(entry(1,string(deals.amount),"."))) = 0 then
                ValData = ValData + ":61:" + substring(string(year(deals.d_date)),3,2) + string(month(deals.d_date),"99") + string(day(deals.d_date),"99") +
                           string(month(deals.d_date),"99") + string(day(deals.d_date),"99") + caps(deals.dc) + replace(trim(string(deals.amount)),'.',',') +
                           "," + vv-code + string(deals.trxtrn) + "//" + caps(trim(deals.dealtrn)) + "\r\n".
                else
                ValData = ValData + ":61:" + substring(string(year(deals.d_date)),3,2) + string(month(deals.d_date),"99") + string(day(deals.d_date),"99") +
                           string(month(deals.d_date),"99") + string(day(deals.d_date),"99") + caps(deals.dc) + replace(trim(string(deals.amount)),'.',',') +
                            vv-code + string(deals.trxtrn) + "//" + caps(trim(deals.dealtrn)) + "\r\n".
            if vv-code = "NCHG" then ValData = ValData + "KOMISSIYA ZA PEREVOD" + "\r\n".
            else do:
                if trim(deals.benfsr) = "" and trim(deals.benacc) = "" and trim(deals.benbank) = "" then do:
                    ValData1 = rus-eng2(trim(deals.dealsdet)).
                    ValData = ValData + substring(trim(ValData1),1,34) + "\r\n".
                end.
                else do:
                    ValData1 = rus-eng2(trim(deals.benacc)).
                    find first remtrz where remtrz.remtrz = trim(deals.dealtrn) no-lock no-error.
                    if available remtrz then v-len = substring(remtrz.actins[1],2,length(remtrz.actins[1]) - 1).
                    else v-len = rus-eng2(trim(deals.benbank)).
                    ValData1 = trim(ValData1) + " " + trim(v-len).
                    ValData = ValData + substring(trim(ValData1),1,34) + "\r\n".
                end.
            end.
        end.
        find first deals where deals.servcode = "cb"  no-error.
        if deals.amount >= 0 then v-dc = "C". else v-dc = "D".
        ValData = ValData + ":62F:"+ v-dc + substring(string(year(deals.d_date)),3,2) + string(month(deals.d_date),"99") + string(day(deals.d_date),"99") +
                getcrc(deals.crc) + replace(trim(string(deals.amount)),'.',',') +  "\r\n".
        ValData = ValData + "-}".

def stream v-out.
output stream v-out to swmt950.txt.
put stream v-out unformatted  ValData.
output stream v-out close.
unix silent value("cptwin swmt950.txt notepad").
/* --------------------------------------------------------------------- */


def var v-path   as char init "swmt950.txt".
/*def var v-path   as char init "/data/export/mt103/swmt950.txt".*/
def var v-result as char .

 v-result = "".
 input through value ("scp -i $HOME/.ssh/id_swift -o PasswordAuthentication=no " + v-path + " r00t@192.168.222.229:/swift/in/").
 repeat:
  import unformatted v-result.
 end.

if v-result <> "" then do:
  message skip " Произошла ошибка при копировании файла swmt950"  skip(1) v-result
          view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.
else do:
   v-result = "".
   input through value ("rm " + v-path).
   repeat:
     import v-result.
   end.

   if v-result <> "" then do:
      message skip " Произошла ошибка при удалении файла " v-path skip(1) v-result
          view-as alert-box buttons ok title " ОШИБКА ! ".
      return.
   end.

  message "Отправка на сервер SWIFT завершена!".
  pause 3.
end.
