/* pcstdog.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Staff, Salary: Печать договора текущего счета
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-1-3
 * AUTHOR
        20/06/2012 id00810
 * BASES
 		BANK COMM
 * CHANGES
        12/07/2012 id00810 - исправлена ошибка в определении названия города на казахском
        25/10/2013 id00800 -  ТЗ 2166 добавила *filialnameru* и *filialnamekz*
*/

def shared var s-aaa like aaa.aaa.
def shared var s-cword as char.
def var v-ifile       as char no-undo init '/data/export/sp_aaacfl.htm'.
def var v-ofile       as char no-undo init 'aaacfl.htm'.
def var vpoint        like point.point no-undo.
def var vdep          like ppoint.dep  no-undo.
def var v-otvlico     as char no-undo.
def var v-stamp       as char no-undo.
def var v-dogsgn      as char no-undo.
def var v-str         as char no-undo.
def var v-kval        as char no-undo.
def var v-rval        as char no-undo.
def var v-acla        as char no-undo.
def var v-kacla       as char no-undo.
def var v-kdd         as char no-undo.
def var v-acclist     as char no-undo.
def var v-kazaddr     as char no-undo.
def var v-txt         as char no-undo.
def var v-txtk        as char no-undo.
def var v-tmpstrlist  as char no-undo.
def var v-tmpstrlist1 as char no-undo.
def var vr-mes        as char no-undo.
def var vk-mes        as char no-undo.
def var v-city        as char no-undo.
def var v-kcity       as char no-undo.
def var v-fo          as char no-undo.
def var v-fam         as char no-undo.
def var v-nam         as char no-undo.
def var v-otch        as char no-undo.
def var v-addr        as char no-undo.
def var v-point       as logi no-undo.
def buffer b-sysc for sysc.

def stream v-out.

{global.i}
{nbankBik.i}

find first aaa where aaa.aaa = s-aaa no-lock no-error.
if not avail aaa then return.

if aaa.crc = 1 then assign v-txt = 'в Тенге'
                           v-txtk = 'Те&#1226;геде'.
if aaa.crc = 2 then assign v-txt = 'в Долларах США'
                           v-txtk = 'А&#1178;Ш долларында'.
if aaa.crc = 3 then assign v-txt = 'в Евро'
                           v-txtk = 'Еурода'.

assign
v-tmpstrlist  = "1.&nbsp;&nbsp;" + v-txt  + ", номер Счета (ИИК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + aaa.aaa.
v-tmpstrlist1 = "1.&nbsp;&nbsp;" + v-txtk + ", Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + aaa.aaa.

run defdts(aaa.regdt, output vr-mes, output vk-mes).

find first cif where cif.cif = aaa.cif no-lock no-error.
if not avail cif then return.

assign v-fo   = cif.name
       v-fo   = replace (v-fo, " ", ",")
       v-fam  = entry(1,v-fo)
       v-nam  = entry(2,v-fo)
       v-otch = entry(3,v-fo)
       v-addr = replace (cif.addr[1], ",", ", " ).

find first cmp no-lock no-error.
find first b-sysc where b-sysc.sysc = "citi" no-lock no-error.
if avail b-sysc then v-city = b-sysc.chval.

find first b-sysc where b-sysc.sysc = "kcity" no-lock no-error.
if avail b-sysc then v-kcity = b-sysc.chval.
else v-kcity = v-city.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
assign vpoint = integer(ofc.regno / 1000)
       vdep   = ofc.regno mod 1000.

find first ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" and aaa.sta <> "C" then do:
     assign v-otvlico = "sp_" + string(ppoint.depart) + "_" + string("1")
            v-stamp   = "stamp_" + v-otvlico
            v-dogsgn  = "dogsgn_" + v-otvlico
            v-point   = yes.

     find first codfr where codfr.code = v-otvlico no-lock no-error.
     if not avail codfr or trim(codfr.name[1]) = "" then assign v-stamp = "" v-dogsgn = "".
end.
else do:
    find first sysc where sysc.sysc = "otvlico" no-lock no-error.
    if avail sysc then v-otvlico = sysc.chval.
    else v-otvlico = "1".
end.

output stream v-out to value(v-ofile).
input from value(v-ifile).

repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*rcity*" then do:
            if v-point then  v-str = replace (v-str, "rcity", ENTRY(2,ENTRY(1,trim(ppoint.info[5])),".") ).
            else v-str = replace (v-str, "rcity", v-city ).
            next.
        end.

        if v-str matches "*kcity*" then do:
            if v-point then v-str = replace (v-str, "kcity", ENTRY(1,ENTRY(1,trim(ppoint.info[6]))," ") ).
            else v-str = replace (v-str, "kcity", v-kcity).
            next.
        end.

        if v-str matches "*kmes*" then do:
           v-str = replace (v-str, "kmes", vk-mes ).
           next.
        end.

        if v-str matches "*rmes*" then do:
           v-str = replace (v-str, "rmes", vr-mes ).
           next.
        end.

        if v-str matches "*rchs*" then do:
           v-str = replace (v-str, "rchs", string(day(aaa.regdt),"99") ).
           next.
        end.

        if v-str matches "*yyyy*" then do:
           v-str = replace (v-str, "yyyy", string(year(aaa.regdt)) ).
           next.
        end.

        if v-str matches "*kdover*" then do:
            find first codfr where codfr.codfr = "DKOSNKZ" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "kdover", codfr.name[1]).
            else v-str = replace (v-str, "kdover", "&nbsp;&nbsp;" ).
           next.
        end.

        if v-str matches "*rdover*" then do:
            find first codfr where codfr.codfr = "DKOSN" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "rdover",  codfr.name[1] ).
            else v-str = replace (v-str, "rdover", "&nbsp;&nbsp;" ).
            next.
        end.

        if v-str matches "*kdolzhni*" then do:
            find first codfr where codfr.codfr = "DKKOGOKZ" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "kdolzhni", ENTRY(1,codfr.name[1],",")).
            else v-str = replace (v-str, "kdolzhni", "&nbsp;&nbsp;" ).
            next.
        end.

        if v-str matches "*rdolzhnr*" then do:
            find first codfr where codfr.codfr = "DKKOGO" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "rdolzhnr", ENTRY(1,codfr.name[1],",")).
            else v-str = replace (v-str, "rdolzhnr", "&nbsp;&nbsp;" ).
            next.
        end.

        if v-str matches "*kfilchifi*" then do:
            find first codfr where codfr.codfr = "DKKOGOKZ" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "kfilchifi", ENTRY(2,codfr.name[1],",")).
            else v-str = replace (v-str, "kfilchifi", "&nbsp;&nbsp;" ).
            next.
        end.

        if v-str matches "*rfilchifr*" then do:
            find first codfr where codfr.codfr = "DKKOGO" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "rfilchifr", ENTRY(2,codfr.name[1],",")).
            else v-str = replace (v-str, "rfilchifr", "&nbsp;&nbsp;" ).
            next.
        end.

        if v-str matches "*rdolzhn*" then do:
            find first codfr where codfr.codfr = "DKDOLZHN" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "rdolzhn",codfr.name[1]).
            else v-str = replace (v-str, "rdolzhn", "&nbsp;&nbsp;" ).
            next.
        end.

        if v-str matches "*rfiochif*" then do:
            find first codfr where codfr.codfr = "DKPODP" and codfr.code = v-otvlico no-lock no-error.
            if avail codfr then v-str = replace (v-str, "rfiochif",codfr.name[1]).
            else v-str = replace (v-str, "rfiochif", "&nbsp;&nbsp;" ).
            next.
        end.

        if v-str matches "*familia*" then do:
           v-str = replace (v-str, "familia", v-fam ).
           next.
        end.

        if v-str matches "*nameofclient*" then do:
           v-str = replace (v-str, "nameofclient", v-nam ).
           next.
        end.

        if v-str matches "*snameofcln*" then do:
           if v-nam <> "" then v-str = replace (v-str, "snameofcln", substr(v-nam,1,1) + ".").
           else v-str = replace (v-str, "snameofcln", " ").
           next.
        end.

        if v-str matches "*othestvoclienta*" then do:
           v-str = replace (v-str, "othestvoclienta", v-otch ).
           next.
        end.

        if v-str matches "*sothestvocln*" then do:
           if v-otch <> "" then v-str = replace (v-str, "sothestvocln", substr(v-otch,1,1) + "." ).
           else v-str = replace (v-str, "sothestvocln", " " ).
           next.
        end.

        if v-str matches "*$cword$*" then do:
           v-str = replace (v-str, "$cword$", s-cword ).
           next.
        end.

        if v-str matches "*raaalist*" then do:
           v-str = replace (v-str, "raaalist", v-tmpstrlist ).
           next.
        end.

        if v-str matches "*kaaalist*" then do:
           v-str = replace (v-str, "kaaalist", v-tmpstrlist1 ).
           next.
        end.

        if v-str matches "*adresclienta*" then do:
           v-str = replace (v-str, "adresclienta", v-addr ).
           next.
        end.

        if v-str matches "*telclienta*" then do:
           v-str = replace (v-str, "telclienta", cif.tel ).
           next.
        end.

        if v-str matches "*rnnclienta*" then do:
           v-str = replace (v-str, "rnnclienta", cif.jss ).
           next.
        end.

        if v-str matches "*iincln*" then do:
           v-str = replace (v-str, "iincln", cif.bin ).
           next.
        end.

        if v-str matches "*raddrbank*" then do:
           if v-point then v-str = replace (v-str, "raddrbank", trim(ppoint.info[5]) ).
           else v-str = replace (v-str, "raddrbank", cmp.addr[1] ).
           next.
        end.
        if v-str matches "*telbank*" then do:
           if v-point then v-str = replace (v-str, "telbank", trim(ppoint.info[7]) ).
           else v-str = replace (v-str, "telbank", cmp.tel ).
           next.
        end.
        if v-str matches "*kaddrbank*" then do:
           if v-point then v-str = replace (v-str, "kaddrbank", trim(ppoint.info[6]) ).
           else do:
            find sysc where sysc.sysc = "bnkadr" no-lock no-error.
            if avail sysc then v-kazaddr = entry(11, sysc.chval, "|") no-error.
            v-str = replace (v-str, "kaddrbank", v-kazaddr ).
           end.
           next.
        end.

        if v-str matches "*rnnbank*" then do:
            v-str = replace (v-str, "rnnbank", cmp.addr[2] ).
            next.
        end.

        if v-str matches "*bicbank*" then do:
           v-str = replace (v-str, "bicbank", v-clecod ).
           next.
        end.
        if v-str matches "*namebankDgv*" then do:
           v-str = replace (v-str, "namebankDgv", v-nbankDgv ).
           next.
        end.
        if v-str matches "*namebankfil*" then do:
           v-str = replace (v-str, "namebankfil", v-nbankfil ).
           next.
        end.

         if v-str matches "*filialnameru*" then do:
            v-str = replace (v-str, "filialnameru", cmp.name ) no-error.
            next.
         end.

         find sysc where sysc.sysc = "bnkadr" no-lock no-error.
         if v-str matches "*filialnamekz*" then do:
            v-str = replace (v-str, "filialnamekz", entry(14, sysc.chval, "|") ) no-error.
            next.
         end.

        if v-str matches "*binbank*" then do:
           find sysc where sysc.sysc = "bnkbin" no-lock no-error.
           if avail sysc then v-str = replace (v-str, "binbank", sysc.chval ).
           else v-str = replace (v-str, "binbank", "&nbsp;&nbsp;" ).
           next.
        end.

        leave.
     end.
     put stream v-out unformatted v-str skip.
end.

input close.
output stream v-out close.
unix silent cptunkoi value(v-ofile) winword.
unix silent value("rm -r " + v-ofile).

procedure defdts:
def input parameter p-dt as date.
def output parameter p-datastr as char.
def output parameter p-datastrkz as char.
def var v-monthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".
def var v-monthnamekz as char init
   "&#1179;а&#1187;тар,а&#1179;пан,наурыз,с&#1241;уiр,мамыр,маусым,шiлде,тамыз,&#1179;ырк&#1199;йек,&#1179;азан,&#1179;араша,желто&#1179;сан".

p-datastr = entry(month(p-dt), v-monthname).
p-datastrkz = entry(month(p-dt), v-monthnamekz).

end.

