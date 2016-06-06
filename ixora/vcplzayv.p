/* vcplzayv.p
 * MODULE
        Операции
 * DESCRIPTION
        Распечатка заявлениея на перевод для Интернет-платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        02/10/2009 galina
 * BASES
        BANK COMM
 * CHANGES
*/



def var v-rdt as char no-undo.
def var v-clname as char no-undo.
def var v-clrnn as char no-undo.
def var v-clcontact as char no-undo.
def var v-cliik as char no-undo. 
def var v-clres as char no-undo. 
def var v-clsec as char no-undo. 
def var v-sbname as char no-undo.
def var v-sbic as char no-undo.
def var v-dtval as char no-undo.
def var v-crc1 as char no-undo.
def var v-crc2 as char no-undo.
def var v-crc3 as char no-undo.
def var v-sum as char no-undo.
def var v-sumwrd as char no-undo.
def var v-benname as char no-undo.
def var v-beniik  as char no-undo.
def var v-country  as char no-undo.
def var v-benres  as char no-undo.
def var v-bensec  as char no-undo.
def var v-brnn as char no-undo. 
def var v-rbname as char no-undo. 
def var v-corbank as char no-undo. 
def var v-swift as char no-undo. 
def var v-swift1 as char no-undo. 
def var v-comacc as char no-undo. 
def var v-rem as char no-undo. 
def var v-knp as char no-undo. 
def var v-chif as char no-undo. 
def var v-mainbk as char no-undo. 
def var v-plsumm as char no-undo.
def var v-plsumm1 as char no-undo.
def var v-crc4 as char no-undo.
def var v-crc5 as char no-undo.
def var v-infile as char no-undo.
def var v-ofile as char no-undo.
def var v-str as char no-undo.
def var v-plnum as char no-undo.
def stream v-out.

def shared var s-remtrz like remtrz.remtrz.

/*s-remtrz = 'RMZA017326'.*/
unix silent value('scp -q /data/docs/image004.gif Administrator@`askhost`:C:/tmp/').
find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if not avail remtrz then next.

v-plnum = substr(remtrz.sqn,19).
find first doc where doc.remtrz = s-remtrz no-lock no-error.
if not avail doc then next.

find first cif where cif.cif = doc.cif no-lock no-error.
if not avail cif then next.
if cif.type = 'P' then next.

assign v-clcontact = cif.addr[1] + ' ' + cif.addr[2] + cif.tel
       v-clres = substr(cif.geo,3,1).

find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' no-lock no-error.
if avail sub-cod then v-clsec = sub-cod.ccode.

find first bankl where bankl.bank = doc.obplc no-lock no-error.
if avail bankl then assign v-sbname = bankl.name
                           v-sbic = bankl.crbank.
find first crc where  crc.crc = doc.crccrc no-lock no-error.
if avail crc then assign v-crc1 = substr(crc.code,1,1)
                         v-crc2 = substr(crc.code,2,1)
                         v-crc3 = substr(crc.code,3,1).

find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = 'iso3166' no-lock no-error.
if avail sub-cod and sub-cod.ccode <> 'msc' then v-country = sub-cod.ccode.

find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'clnchf' no-lock no-error.
if avail sub-cod then v-chif = sub-cod.rcode.
find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'clnbk' no-lock no-error.
if avail sub-cod then v-mainbk =  sub-cod.rcode.

v-sum = replace(trim(string(doc.amt, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").
run Sm-vrd (doc.amt, output v-plsumm).
run Sm-vrd (deci(entry(2,v-sum,'.')), output v-plsumm1).
run sm-wrdcrc (substr(v-sum, 1, length(v-sum) - 3), 
                       substr(v-sum, length(v-sum) - 1), 
                       doc.crccrc, output v-crc4, output v-crc5).
v-sumwrd = v-plsumm + " " + v-crc4 + " " + v-plsumm1 + " " + v-crc5.
if entry(3,doc.codepar[2],'/') = 'R' then v-benres = '1'. else v-benres = '2'.
assign v-rdt = string(doc.depdate,'99/99/9999')
       v-clname = doc.filial
       v-clrnn = doc.regcode
       v-cliik = doc.ordacc
       v-dtval = string(doc.valdate,'99/99/9999')
       v-benname = doc.benname[2]
       v-beniik = doc.benacc
       v-bensec = doc.bbinfo[1]
       v-brnn = doc.benname[1]
       v-rbname = doc.bbname[1]
       v-corbank = doc.ibname[2]
       v-swift = bbcode[1] + ' ' + bbcode[2]
       v-swift1 = ibcode[1] + ' ' + ibcode[2]
       v-comacc = doc.comacc
       v-rem = beninfo[1] + ' ' + beninfo[2]+ ' ' + beninfo[3] + ' ' + beninfo[4]
       v-knp = doc.bbinfo[2].
 
if trim(v-rbname) = '' then do:
   find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
   if avail remtrz then v-rbname = bankl.name.  
end.   
if trim(v-clname) = '' then v-clname = cif.prefix + ' ' + cif.name.
if trim(v-swift) = '' then v-swift = doc.bbplc.

v-infile  = "/data/docs/vcplzayv.htm".
v-ofile = "vcplzaya1.htm".
output stream v-out to value(v-ofile).
    /********/
    
input from value(v-infile).
repeat:
   import unformatted v-str.
   v-str = trim(v-str).
        
   repeat:
     if v-str matches "*\{\&v-plnum\}*" then do:
        v-str = replace (v-str, "\{\&v-plnum\}", v-plnum).
        next.
     end.

     if v-str matches "*\{\&v-rdt\}*" then do:
        v-str = replace (v-str, "\{\&v-rdt\}", v-rdt).
        next.
     end.

     if v-str matches "*\{\&v-clname\}*" then do:
        v-str = replace (v-str, "\{\&v-clname\}", v-clname).
        next.
     end.

     if v-str matches "*\{\&v-clrnn\}*" then do:
        v-str = replace (v-str, "\{\&v-clrnn\}", v-clrnn).
        next.
     end.


     if v-str matches "*\{\&v-cliik\}*" then do:
        v-str = replace (v-str, "\{\&v-cliik\}", v-cliik).
        next.
     end.
     if v-str matches "*\{\&v-clcontact\}*" then do:
        v-str = replace (v-str, "\{\&v-clcontact\}", v-clcontact).
        next.
     end.


     if v-str matches "*\{\&v-clres\}*" then do:
        v-str = replace (v-str, "\{\&v-clres\}", v-clres).
        next.
     end.
     
     if v-str matches "*\{\&v-clsec\}*" then do:
        v-str = replace (v-str, "\{\&v-clsec\}", v-clsec).
        next.
     end.
     
     if v-str matches "*\{\&v-sbname\}*" then do:
        v-str = replace (v-str, "\{\&v-sbname\}", v-sbname).
        next.
     end.

     if v-str matches "*\{\&v-sbic\}*" then do:
        v-str = replace (v-str, "\{\&v-sbic\}", v-sbic).
        next.
     end.

     if v-str matches "*\{\&v-dtval\}*" then do:
        v-str = replace (v-str, "\{\&v-dtval\}", v-dtval).
        next.
     end.

     if v-str matches "*\{\&v-sum\}*" then do:
        v-str = replace (v-str, "\{\&v-sum\}", v-sum).
        next.
     end.
            
     if v-str matches "*\{\&v-sumwrd\}*" then do:
        v-str = replace (v-str, "\{\&v-sumwrd\}", v-sumwrd).
        next.
     end.
     
     if v-str matches "*\{\&v-benname\}*" then do:
        v-str = replace (v-str, "\{\&v-benname\}", v-benname).
        next.
     end.

     if v-str matches "*\{\&v-beniik\}*" then do:
        v-str = replace (v-str, "\{\&v-beniik\}", v-beniik).
        next.
     end.

     if v-str matches "*\{\&v-benres\}*" then do:
        v-str = replace (v-str, "\{\&v-benres\}", v-benres).
        next.
     end.
     
     if v-str matches "*\{\&v-bensec\}*" then do:
        v-str = replace (v-str, "\{\&v-bensec\}", v-bensec).
        next.
     end.

     if v-str matches "*\{\&v-country\}*" then do:
        v-str = replace (v-str, "\{\&v-country\}", v-country).
        next.
     end.
     
     if v-str matches "*\{\&v-brnn\}*" then do:
        v-str = replace (v-str, "\{\&v-brnn\}", v-brnn).
        next.
     end.
     
     if v-str matches "*\{\&v-rbname\}*" then do:
        v-str = replace (v-str, "\{\&v-rbname\}", v-rbname).
        next.
     end.

     if v-str matches "*\{\&v-corbank\}*" then do:
        v-str = replace (v-str, "\{\&v-corbank\}", v-corbank).
        next.
     end.

     if v-str matches "*\{\&v-swift\}*" then do:
        v-str = replace (v-str, "\{\&v-swift\}", v-swift).
        next.
     end.

     if v-str matches "*\{\&v-swift1\}*" then do:
        v-str = replace (v-str, "\{\&v-swift1\}", v-swift1).
        next.
     end.

     if v-str matches "*\{\&v-comacc\}*" then do:
        v-str = replace (v-str, "\{\&v-comacc\}", v-comacc).
        next.
     end.

     if v-str matches "*\{\&v-rem\}*" then do:
        v-str = replace (v-str, "\{\&v-rem\}", v-rem).
        next.
     end.

     if v-str matches "*\{\&v-knp\}*" then do:
        v-str = replace (v-str, "\{\&v-knp\}", v-knp).
        next.
     end.

     if v-str matches "*\{\&v-crc1\}*" then do:
        v-str = replace (v-str, "\{\&v-crc1\}", v-crc1).
        next.
     end.

     if v-str matches "*\{\&v-crc2\}*" then do:
        v-str = replace (v-str, "\{\&v-crc2\}", v-crc2).
        next.
     end.

     if v-str matches "*\{\&v-crc3\}*" then do:
        v-str = replace (v-str, "\{\&v-crc3\}", v-crc3).
        next.
     end.

     if v-str matches "*\{\&v-chif\}*" then do:
        v-str = replace (v-str, "\{\&v-chif\}", v-chif).
        next.
     end.

     if v-str matches "*\{\&v-mainbk\}*" then do:
        v-str = replace (v-str, "\{\&v-mainbk\}", v-mainbk).
        next.
     end.
     leave.
   end. /* repeat */
        
        put stream v-out unformatted v-str skip.
end. /* repeat */
input close.
/********/    
    
output stream v-out close.
output stream v-out to value(v-ofile) append.
output stream v-out close.
unix silent value("cptwin " + v-ofile + " winword").
unix silent value("rm -r " + v-ofile).