/* lb100smp.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Программа формирования файла сообщения по СМЭП при выгрузке
 * RUN

 * CALLER
        lb100.p, lb100g.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        19.08.2013 galina ТЗ1871
 * CHANGES
 * BASES
        BANK COMM
*/

{chbin.i}
def input parameter iddat as date.
/*def input parameter v-paysys as char.*/
def input parameter p-cnt as integer.
def output parameter amttot like remtrz.payment.
def output parameter cnt as integer.

def shared var g-today as date .
def shared var g-ofc as cha .
def shared var v-text as cha .
def shared var vnum as int .

def var v-namebnk as char.
def var v-ks as char .  /* v-ba */
def buffer u-remtrz for remtrz .
def buffer t-bankl for bankl.
def var i as int.
def var v-unidir as cha .
def var ii as int .
def var v-dt as cha .
def var t-amt as cha .
def var v-name as char.
define variable vdetpay as character .
def var eknp-code as char.
def var filenum as int .
def var filenumstr as char.
def var daynum as cha .
def var v-tnum as char.
def var v-clecod as cha.
def var v-knp as char init "000".

def stream prot .
def stream main .

/*****/
def shared temp-table t-docsmep
  field bstr as char
  field rem as char
  field sbank as char
  field sacc as char
  field rbank as char
  field racc as char
  index main sbank sacc rbank racc rem.

/***/
def var ourbank as cha .
def var v-lbmfo as cha .
def var ourbic as cha .
def var lbbic as cha .
def var regs as cha .
def var v-oirs as cha no-undo.
def var v-oseco as cha no-undo.
def var v-birs as cha no-undo.
def var v-bseco as cha no-undo.
def var v-on as cha .
def var v-bn as cha .
def var v-tmp as  cha .

def var v-ks1 as char .  /* v-ba */
def var n as int .

{mycustomer.i}
{lb100s.i "'SMP'"}

/* обнулим счетчик файлов */
filenum = 0.
{trim.i}

/* sasco *************************************************/
FUNCTION ToNumber returns char (inchar as char).
	DEF VAR tt as int.
	DEF VAR oc as char.
	oc = inchar.
	do tt = 0 to 255:
		if tt < 48 or tt > 57 then
			oc = GReplace (oc, CHR(tt), "").
	end.
	do WHILE LENGTH (oc) > 9:
		oc = SUBSTR (oc, 2).
	end.
        if oc = "" then oc = "бн".
	RETURN oc.
END FUNCTION.
/* sasco *************************************************/


find first t-docsmep  no-error.
/* если нет таких платежей -> выход */
if not available t-docsmep  then return.
unix silent value("/bin/rm -f " + v-unidir + "p*.eks " + v-unidir + "*.err " + v-unidir +  "m*.eks  &> /dev/null ") .

do transaction :
  amttot = 0.
  daynum = string(g-today - date(12, 31, year(g-today) - 1), "999") .
  output stream prot to value(v-unidir + "m" + daynum + string(vnum * 100, "99999") + ".eks").
  /*output stream prot to value(v-unidir + "m" + daynum + string(vnum * 100, "99999") + ".eks") append.*/

  for each t-docsmep  no-lock  break by t-docsmep.sbank by t-docsmep.sacc by t-docsmep .rbank by t-docsmep.racc:

    find first remtrz where remtrz.remtrz = t-docsmep.rem no-lock no-error.
    if not avail remtrz then next.
    if remtrz.cover <> 6 then next.

    find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
    if not avail bankl then next.

    output stream main to value("/tmp/ttt.eks") .

    filenum = 1 + vnum * 100. /* 0 - пенсионные, 1 - обычные, 2 - налоговые по новой форме */
    filenumstr = string(filenum,"99999").

    find crc where crc.crc = remtrz.tcrc no-lock no-error.
    find first t-bankl where t-bankl.bank = remtrz.sbank no-lock no-error.
    find first bankt where bankt.cbank = remtrz.sbank and bankt.crc = remtrz.tcrc no-lock no-error.

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock use-index dcod no-error.
    if avail sub-cod and sub-cod.rcod matches "*,*,*" then do:
           v-oirs = substr(entry(1,sub-cod.rcod,","),1,1).
	       v-oseco = substr(entry(1,sub-cod.rcod,","),2,1).
           v-birs = substr(entry(2,sub-cod.rcod,","),1,1).
	       v-bseco = substr(entry(2,sub-cod.rcod,","),2,1).
           v-knp =  entry(3,sub-cod.rcod,",") .
    end.
    else do:
          v-oirs = "".
	      v-oseco = "".
          v-birs = "".
          v-bseco = "".
          v-knp = "000".
    end.


    t-amt = trim(string(remtrz.payment, "zzzzzzzzzzzzzzz9.99-")).
    if index(t-amt,".") > 0 then t-amt = replace(t-amt, ".", ",").

    put stream main unformatted "\{1:" +  v-tnum + "\}" skip
                                "\{2:I100SMEP00000000U3003\}" skip
                                "\{4:" skip
                                ":20:" remtrz.remtrz skip
                                ":32A:" substring(string(year(iddat)),3,2) month(iddat)
                                 format "99" day(iddat) format "99"
                                 crc.code format "x(3)"
                                  t-amt skip .
	v-on = myCustomer("/NAME/" + remtrz.ord + " " , remtrz.sacc, "50", remtr.remtrz ).
	v-bn = myCustomer("/NAME/" + remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3] + " ", remtrz.ba, "59", remtrz.remtrz ).

    if v-bin = yes then v-on = replace(v-on,"RNN","IDN").
	put stream main unformatted  caps(v-on).

    if v-oirs <> "" then put stream main unformatted "/IRS/" + v-oirs skip.
    if v-oseco <> "" then put stream main unformatted "/SECO/" + v-oseco skip.

	put stream main unformatted	":52B:" + trim(v-clecod) skip
								":57B:" + trim(remtrz.rbank) skip.





    if v-bin = yes then v-bn = replace(v-bn,"RNN","IDN").
	put stream main unformatted  caps(v-bn).

    if v-birs <> "" then put stream main unformatted "/IRS/" + v-birs  skip.
    if v-bseco <> "" then put stream main unformatted "/SECO/" + v-bseco  skip.
    put stream main unformatted ":70:/NUM/" + ToNumber(substr(remtrz.sqn,19)) skip
                                "/DATE/" + substr(string(year(remtrz.valdt1)),3,2) + string(month(remtrz.valdt1),"99") + string(day(remtrz.valdt1),"99") skip
                                "/SEND/07" skip
                                "/VO/01" skip
                                "/KNP/" + v-knp skip
						        "/PSO/01" skip
                                "/PRT/50" skip.

    if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then  put stream main unformatted "/BCLASS/" + v-ks1 skip.

    v-dt = "/ASSIGN/".

    vdetpay = "" .
    do ii = 1 to 4:
       vdetpay = vdetpay + trim(remtrz.detpay[ii]).
    end.

    if vdetpay <> "" then do:
       if length (vdetpay) > 41 then do:
          if length (vdetpay) > 111 then do:
             if length (vdetpay) > 181 then do:
                if length (vdetpay) > 251 then do:
                   if length (vdetpay) > 321 then do:
                      if length (vdetpay) > 391 then
                        v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182,70)
                          + chr(10) + substring (vdetpay,252,70)
                          + chr(10) + substring (vdetpay,322,70).
                   else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182,70)
                          + chr(10) + substring (vdetpay,252,70)
                          + chr(10) + substring (vdetpay,322).
                   end.
                   else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182,70)
                          + chr(10) + substring (vdetpay,252).
                end.
                else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112,70)
                          + chr(10) + substring (vdetpay,182).

             end.
             else v-dt = v-dt + substring (vdetpay,1,41)
                          + chr(10) + substring (vdetpay,42,70)
                          + chr(10) + substring (vdetpay,112) .
          end.
          else v-dt = v-dt + substring (vdetpay,1,41) + chr(10) + substring (vdetpay,42).
       end.
       else v-dt = v-dt + vdetpay .
    end.
    v-dt = v-dt + chr(10).

    put stream main unformatted caps(v-dt) + "-}" skip.

    do:
       find first u-remtrz where remtrz.remtrz = u-remtrz.remtrz exclusive-lock.
       u-remtrz.t_sqn = remtrz.remtrz.
       u-remtrz.ref = "p" + daynum + filenumstr + ".eks/102/".
    end.


    cnt = cnt + 1.
    amttot = amttot + remtrz.payment.

    put stream prot unformatted p-cnt + cnt ":" trim(remtrz.remtrz)
    if index(remtrz.sqn, ".", 19) = 0 then caps(substring(remtrz.sqn, 19))
    else caps(substring(remtrz.sqn, 19,index(remtrz.sqn, ".", 19) - 19)) ":"
    v-ks ":" remtrz.payment " - p" + daynum + filenumstr + ".eks"  skip.

    output stream main close .

    if filenum > 0 then do:
      unix silent value("cat /tmp/ttt.eks >>" + v-unidir + "p" + daynum + filenumstr + ".eks").
      unix silent /bin/rm -f /tmp/ttt.eks.
    end.
 end. /*  for each  t-docsmep   */

end. /*do transaction*/

put stream prot unformatted	"Total docs:" cnt skip
		                    "Total amount:" amttot skip .

output stream prot close.

