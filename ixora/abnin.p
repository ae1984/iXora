/* abnin.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Создает платеж, присваивает все поля
 * RUN
        Из пункта меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        n-remtrz - создает новый RMZ
 * MENU
        
 * AUTHOR
        хх.хх.2006 - suchkov 
 * CHANGES
*/

define new shared variable s-remtrz like remtrz.remtrz .
define shared variable g-ofc like remtrz.remtrz .
define variable vfilename as character                 no-undo.
define variable vstring   as character                 no-undo.
define variable vcrc      as decimal                   no-undo.
define variable vset      as logical initial false     no-undo.
define variable varp      as character                 no-undo.
define variable vba       as character                 no-undo.
define variable vdracc    as character                 no-undo.
define variable abnbnk    as character 		       no-undo.

define temp-table t-abn no-undo
	field vamt   as decimal 
	field vref   as character 
	field detpay as character .

find sysc where sysc.sysc = "abnbnk" exclusive-lock no-error .
if not avail sysc then do: 
	create sysc.
	assign sysc.chval = "ABN-2" sysc.sysc = "abnbnk" sysc.des = "Банк для обработки".
end. 
abnbnk = sysc.chval. 

update vfilename label "Введите имя файла             " format "x(20)" skip
       abnbnk    label "Введите имя банка для загрузки" format "x(20)" with side-labels centered .

sysc.chval = abnbnk .

unix silent value("rcp `askhost`:c:\\\\" + vfilename + " .").
input from value(vfilename) .
create t-abn .
repeat:
import vstring .
if vstring begins ":25:" then do:
	vdracc = substring (vstring,5,length(vstring) - 7) .
	find crc where crc.code = substring (vstring,length(vstring) - 2, 3) no-lock no-error .
	if not available crc then do:
		message "Внимание! Валюта " substring (vstring,length(vstring) - 2, 3) " не найдена!" view-as alert-box.
		next.
	end.
	vcrc = crc.crc .
end.
if vset then do:
	t-abn.detpay = vstring .
	vset = false .
	next .
end.
if vstring begins ":61:" then do:
	if substring (vstring,15,1) = "D" then next . /* Дебет - идем дальше */
	if substring (vstring,15,1) <> "C" then do:
		message "Внимание! Признак дебет/кредит - " substring (vstring,15,1) " не опознан!" view-as alert-box.
		next.
	end.
	create t-abn .
        t-abn.vamt = decimal(replace (substring (vstring,16,length(ENTRY(1,substring(vstring,16))) + 3),",",".")).
        t-abn.vref = substring (vstring,16 + length(ENTRY(1,substring(vstring,16))) + 4).
	vset = true .
end.
end.
input close. 

find first t-abn .
delete t-abn.

if vcrc = 1 then
        assign
	vba  = "000170002" 
	varp = "001904442" .
if vcrc = 2 then
        assign
	vba  = "002072221" 
	varp = "001076642" .

find first dfb where dfb.dfb = vba no-lock no-error .
if not available dfb then do:
	message "Внимание! Счет " vba " не найден!" view-as alert-box.
	quit.
end.

find first arp where arp.arp = varp no-lock no-error .
if not available arp then do:
	message "Внимание! Счет " varp " не найден!" view-as alert-box.
	quit.
end.



for each t-abn. /*display t-abn . */

    run n-remtrz. 

    create remtrz .
    assign remtrz.source    = "ABN"
           remtrz.rtim      = time
           remtrz.t_sqn     = ""
           remtrz.rdt       = today
           remtrz.remtrz    = s-remtrz 
           remtrz.rwho      = g-ofc
           remtrz.valdt1    = today
           remtrz.tcrc      = vcrc
           remtrz.payment   = t-abn.vamt
           remtrz.fcrc      = vcrc
           remtrz.amt       = t-abn.vamt
           remtrz.jh1       = ?  
           remtrz.jh2       = ? 
           remtrz.ord       = "/ABN-AMRO BANK"
           remtrz.bb[1]     = '/AO "TEXAKABANK" Алматы, ул.Калдаяко'
           remtrz.bb[2]     = "ва,28"
           remtrz.actins[1] = '/AO "TEXAKABANK" Алматы, ул.Калдаяко'
           remtrz.actins[2] = "ва,28"                               
           remtrz.bn[1]     = '/AO "TEXAKABANK" Алматы, ул.Калдаяко'
           remtrz.bn[2]     = "ва,28"                                
           remtrz.detpay[1] = substr(t-abn.detpay,1,35) 
           remtrz.detpay[2] = substr(t-abn.detpay,36,35) 
           remtrz.detpay[3] = substr(t-abn.detpay,71,35) 
           remtrz.detpay[4] = substr(t-abn.detpay,106) 
           remtrz.ba        = vba
           remtrz.bi        = "BEN"
           remtrz.margb     = 0
           remtrz.margs     = 0
           remtrz.svca      = 0
           remtrz.svcaaa    = ""
           remtrz.svcmarg   = 0
           remtrz.svcp      = 0
           remtrz.svcrc     = 1
           remtrz.svccgl    = 0
           remtrz.svcgl     = 0
           remtrz.dracc     = dfb.dfb
           remtrz.drgl      = dfb.gl
           remtrz.sqn       = t-abn.vref + ".." + s-remtrz
           remtrz.rcbank    = "TXB00"
           remtrz.rbank     = "TXB00"
           remtrz.racc      = arp.arp
           remtrz.outcode   = 3
           remtrz.scbank    = abnbnk
           remtrz.sbank     = abnbnk
           remtrz.actinsact = remtrz.rbank
           remtrz.rsub      = "arp"
           remtrz.raddr     = ""
           remtrz.cracc     = arp.arp 
           remtrz.crgl      = arp.gl
           remtrz.ptype     = "7"
           remtrz.cover     = 1
           remtrz.svccgr    = 0
           remtrz.svcrc     = vcrc
           remtrz.ref       = "".
               
    create sub-cod.
    create que.
    assign sub-cod.acc   = remtrz.remtrz
           sub-cod.sub   = "rmz"
           sub-cod.d-cod = "eknp" 
           sub-cod.ccode = "eknp" 
           sub-cod.rcod  = "14,14,150"
           que.remtrz   = remtrz.remtrz
           que.pid      = "WS"
           que.rcid     = recid(remtrz) 
           que.ptype    = remtrz.ptype
           que.rcod     = "1"
           que.con      = "W"
           que.dp       = today
           que.tp       = time
           que.pri      = 29999 .
    create sub-cod.
    assign sub-cod.acc   = remtrz.remtrz
           sub-cod.sub   = "rmz"
           sub-cod.d-cod = "iso3166" 
           sub-cod.ccode = "KZ" .
   
    display remtrz.remtrz .
end.
