/* comm_kvit.i
 * MODULE
       Коммунальные платежи
 * DESCRIPTION
       общая часть всех программ печати квитанций
 * AUTHOR
        23.10.2006  Evgeniy (u00568)
 * CHANGES

*/

/*define input parameter rid as char.*/

{global.i}
{get-dep.i}
{comm-txb.i}
{getfromrnn.i}

def var ckv as int no-undo.
def var ltax as logic init false no-undo.
def var sumchar as char no-undo.
def var v-bank-name as char no-undo.
def var i as int no-undo.
def var mark as int no-undo.
def var s_1 as char no-undo.
def var s_2 as char no-undo.


define var seltxb as int no-undo.
seltxb = comm-cod().

def var crlf as char no-undo.
crlf = /*chr(13) +*/ chr(10).



    find first commonpl where rowid(commonpl) = to-rowid(substring(rid,1,10)) no-lock no-error.
    rid = substring(rid, 11).
    if not available commonpl then do:
       next.
    end.
    /*  счетчик квитанций (sasco) */
    ckv = ?.
    ckv = integer (commonpl.chval[5]) no-error.
    if ckv = ? then ckv = 0.
    ckv = ckv + 1.
    if commonpl.uid = userid ("comtx") then do:
      do transaction:
        find current commonpl exclusive-lock no-error.
        if available commonpl then
          commonpl.chval[5] = string (ckv, "zzz9").
        find current commonpl no-lock no-error.
      end. /*tran*/
    end.
    if not available commonpl then return error.
    /*
    if ckv > 1 then do:
      run second_print(string(rowid(commonpl)) , 'commonpl') no-error.
      IF ERROR-STATUS:ERROR then do:
        return error.
      end.
    end.
    */

    if commonpl.kb > 0 then ltax = true.

    run Sm-vrd(commonpl.sum, output sumchar).

    sumchar = sumchar + ' тенге ' + string((
               if (commonpl.sum - integer(commonpl.sum)) < 0 then 1 + (commonpl.sum - integer(commonpl.sum))
                                                             else (commonpl.sum - integer(commonpl.sum))) * 100,
                                                                    "99") + ' тиын'.

    if length(sumchar) > 69 then
      mark = R-INDEX(sumchar, " ", 69).
    else
      mark = length(sumchar).


    find first commonls where commonls.txb = seltxb
                          and commonls.type = commonpl.type
                          and commonls.grp = commonpl.grp
                          and commonls.visible = commonls_visible
                        no-lock no-error.

    /* Для Ofline PragmaTX была убрана проверка на БИКи полчателей так как синхронизация не происходит день в день,
   а может происходить в несколько дней + нерабочие дни кассира - станции диагностики */

   if avail commonls then do:
     find first bankl where bankl.bank = string(commonls.bikbn) no-lock no-error.
     if avail bankl then
       v-bank-name = bankl.name.
     else
       v-bank-name = "".
   end.
   /*find first bankl where bankl.bank = trim(commonpl.info[3]) no-lock no-error.*/


   /*---БКС---*/
   s_1 = string(commonpl.dnum) + "#" + string(commonpl.npl) + "#" + string(commonpl.sum) + "#" + string(commonpl.comsum) + "#" + "0" + "#" + "KZT".
   s_2 = "NO" + "#" + commonpl.rnnbn  + "#" + commonls.bn + "#" + commonpl.rnn + "#" + commonpl.fioadr.
   /*-------*/
