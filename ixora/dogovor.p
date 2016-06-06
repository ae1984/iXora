﻿/* dogovor.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Повторное формирование отчетов по депозитам
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        20.05.2008 id00004
 * CHANGES
        28/10/2008 madiyar - отредактировал в связи с переходом на новую кодировку
        12/10/2009 id00004 - добавил повторную печать договоров для физических лиц
        17/03/2010 id00004 - добавил формирование догоаоров для счетов KassaNova
        19/01/2011 evseev - изменил &#179 на &#1179 (к - казахская)
        30/05/2011 evseev - добавил схему 6, измнил БИК на БСК в каз. части
        22/07/2011 evseev - тз-1105. печать новых договоров по деп. и тек.счетам
        01/08/2011 evseev - подтягивать печать и подпись для определенных СП-шек
        03/08/2011 evseev - добавил новое значение в отчет
        05/08/2011 evseev - реализация тз-1127
        12/08/2011 evseev - реализация ТЗ-1128
        17/08/2011 evseev - небольшие исправления
        19/08/2011 evseev - округление эфф.ставки до десятых знаков. Письмо от Исайкина А.
        02/09/2011 evseev - добавил 3 валюты
        04.04.2012 id00810 - добавила v-bicbank, v-namebank для печати договоров
        23/04/2012 evseev - rebranding
        25/04/2012 evseev - повтор
        26/04/2012 evseev - повтор
        03/05/2012 evseev - nbankBik.i
        20/06/2012 id00810 - добавлен договор текушего счета по ПК
        11/07/2011 id00810 - добавила название города (каз)
        27/07/2012 id00810 - отдельный список групп счетов по ПК
        28/08/2012 id00810 - перекомпиляция
        25/12/2012 id00810 - добавлены группы счетов 143, 144, 145 для ПК юр.лиц (ТЗ 1470)
        13.05.2013 evseev - tz-1828
        04.06.2013 evseev - tz-1844
        05.06.2013 evseev - tz-1845
*/


{global.i}
{sysc.i}
{nbankBik.i}

def var s-aaa like aaa.aaa.
def var v-ofile as char.
def var v-ifile as char.
def stream v-out.
def var v-str as char.
def var v-acclist as char.
def buffer buf-aaa for aaa.


update s-aaa label "Номер счета" with centered overlay color message row 5 frame f-aaa.
hide frame f-aaa.

find aaa where aaa.aaa = s-aaa no-lock no-error.
if not available aaa then do:
   message "Данный счет не существует" . pause .
   return.
end.
find last cif where cif.cif = aaa.cif no-lock no-error.
find last lgr where lgr.lgr = aaa.lgr no-lock no-error.





   find last crc where crc.crc = aaa.crc no-lock no-error.
   find last cmp no-lock no-error.
/* Формирование договора и отображение в html в зависимости от типа предпринимателя */
/*  if s-okcancel = True then */
   def var vr-mes as char.
   def var vk-mes as char.

   def var vr-period as char.
   def var vk-period as char.

   run defdts(aaa.regdt, output vr-mes, output vk-mes).
   run defdts1(aaa.regdt, aaa.expdt, output vr-period, output vk-period).


def var v-podp as char.
def var v-bickfiliala as char.
def var v-bickfilialakz as char.
find last cmp no-lock no-error.
def buffer bss for sysc.
def buffer bmm for sysc.
find last bmm where bmm.sysc = "OURBNK" no-lock no-error.
if bmm.chval = "TXB00" then v-podp = "Бояркина И.Я.".


 find bss where bss.sysc = "bnkadr" no-lock no-error.
 if num-entries(bss.chval,"|") > 13 then
    v-bickfilialakz = entry(14, bss.chval,"|") + ", " .
    v-bickfilialakz = v-bickfilialakz + "СТТН " + cmp.addr[2] + ", ЖИК " + get-sysc-cha ("bnkiik") + ", БСК " + get-sysc-cha ("clecod") + ", " .

 if num-entries(bss.chval,"|") > 10 then
 v-bickfilialakz = v-bickfilialakz +  entry(11, bss.chval,"|").



 v-bickfiliala = cmp.name + ", " + "РНН " + cmp.addr[2] + ", ИИК " + get-sysc-cha ("bnkiik") + ", БИК " + get-sysc-cha ("clecod") + ", " + cmp.addr[1].

 if bmm.chval = "TXB00" then v-bickfilialakz = "".
 if bmm.chval = "TXB00" then v-bickfiliala = "".

 find last bss where bss.sysc = "DKPODP" no-lock no-error.
 v-podp = bss.chval.
 def buffer bcit for sysc.
 def var v-city  as char no-undo.
 def var v-kcity as char no-undo.
 find last bcit where bcit.sysc = "citi" no-lock no-error.
 if avail bcit then v-city = bcit.chval.
 find last bcit where bcit.sysc = "kcity" no-lock no-error.
 if avail bcit then v-kcity = bcit.chval.
 else v-kcity = v-city.

if bmm.chval = "TXB00" then v-podp = "Бояркина И.Я.".

        v-acclist = "".
        if lookup(lgr.lgr,"151,153,171,157,176,152,154,172,158,177,173,175,174") > 0  then do:
           for each buf-aaa where (buf-aaa.cif = cif.cif) and buf-aaa.sta <> "E" and buf-aaa.sta <> "C" and  (lookup(buf-aaa.lgr,"151,153,171,157,176,152,154,172,158,177,173,175,174") > 0) no-lock:
             if v-acclist <> "" then v-acclist = v-acclist + ",".
             v-acclist = v-acclist + buf-aaa.aaa.
           end.
        end.

        if lookup(lgr.lgr,"202,204,222,208") > 0  then do:
           for each buf-aaa where (buf-aaa.cif = cif.cif) and buf-aaa.sta <> "E" and buf-aaa.sta <> "C" and  (lookup(buf-aaa.lgr,"202,204,222,208") > 0) no-lock:
             if v-acclist <> "" then v-acclist = v-acclist + ",".
             v-acclist = v-acclist + buf-aaa.aaa.
           end.
        end.
        if lookup(lgr.lgr,"138,139,140,143,144,145") > 0  then do:
           for each buf-aaa where (buf-aaa.cif = cif.cif) and buf-aaa.sta <> "E" and buf-aaa.sta <> "C" and  (lookup(buf-aaa.lgr,"138,139,140,143,144,145") > 0) no-lock:
             if v-acclist <> "" then v-acclist = v-acclist + ",".
             v-acclist = v-acclist + buf-aaa.aaa.
           end.
        end.


            def var v-fo as char.
            def var v-fam as char.
            def var v-nam as char.
            def var v-otch as char.
            def var v-acla as char.
            def var v-kacla as char.
            def var v-sumopnam as char.
            def var v-ksumopnam as char.
            def var v-rastr as char.
            def var v-rnost as char.
            def var v-knost as char.
            def var v-tmpstr as char.
            def var v-tmpstr1 as char.
            def var v-kazaddr as char.
            def var i as int.
            def var v-tmpstrlist as char.
            def var v-tmpstrlist1 as char.

            def var v-kval as char.
            def var v-rval as char.

            def var v-kdd as char.
            def var v-rdd as char.
            def var v-kmm as char.
            def var v-rmm as char.
            def var v-kddmm as char.
            def var v-rddmm as char.
            def var v-otvlico as char.

            def  var vpoint like point.point .
            def  var vdep like ppoint.dep .
            def  var v-prefix as char.
            def var v-ipsvidrus as char.
            def var v-ipsvidkz as char.
            def var v-binrus as char.
            def var v-binkz as char.
            def var v-stamp as char.
            def var v-dogsgn as char.




        if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20,B09,B10,B11,B01,B02,B03,B04,B05,B06,B07,B08,A38,A39,A40,A22,A23,A24,A01,A02,A03,A04,A05,A06,246,478,479,480,481,482,483,518,519,520,151,153,171,157,176,152,154,172,158,177,173,175,174,202,204,222,208,138,139,140,143,144,145") > 0  then do:

            find first ofc where ofc.ofc = g-ofc no-lock no-error.
            vpoint =  integer(ofc.regno / 1000).
            vdep = ofc.regno mod 1000.

            find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
            v-stamp = "".
            v-dogsgn = "".
            if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" and aaa.sta <> "C" then do:
                 v-otvlico = "sp_" + string(ppoint.depart) + "_" + string("1").
                 v-stamp = "stamp_" + v-otvlico.
                 v-dogsgn = "dogsgn_" + v-otvlico.

                 find first codfr where codfr.code = v-otvlico no-lock no-error.
                 if not avail codfr or trim(codfr.name[1]) = "" then do:
                    v-stamp = "".
                    v-dogsgn = "".
                 end.
                 /*message v-otvlico. pause.*/
            end.
            else do:
                find first sysc where sysc.sysc = "otvlico" no-lock no-error.
                if avail sysc then v-otvlico = sysc.chval.
                else v-otvlico = "1".
            end.
            v-prefix = "sp_".

            /*
            if avail ppoint and (bmm.chval = "TXB16") then do:
              if ppoint.name matches "*СП-1*" then v-prefix = "sp_".
              if ppoint.name matches "*СП-2*" then v-prefix = "sp_".
              if ppoint.name matches "*ул. Калдаякова, 30*" then v-prefix = "sp_".
            end.
            */

            v-ofile = "ofile.htm" .
            if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "fortemaximum.htm".
            end.
            if lookup(lgr.lgr,"B01,B02,B03,B04,B05,B06,B07,B08") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "forteprofitable.htm".
            end.
            if lookup(lgr.lgr,"B09,B10,B11") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "forteuniversal.htm".
            end.
            if lookup(lgr.lgr,"A22,A23,A24") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "metrolux.htm".
            end.
            if lookup(lgr.lgr,"A38,A39,A40") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "fortelux.htm".
            end.
            if lookup(lgr.lgr,"A01,A02,A03,A04,A05,A06") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "standard.htm".
            end.
            if lookup(lgr.lgr,"246") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "gcvpfl.htm".
            end.
            if lookup(lgr.lgr,"478,479,480,481,482,483") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "srochnyi.htm".
            end.
            if lookup(lgr.lgr,"518,519,520") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "nedropol.htm".
            end.
            if lookup(lgr.lgr,"151,153,171,157,176,152,154,172,158,177,173,175,174") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaaul.htm".
            end.
            if lookup(lgr.lgr,"202,204,222,208") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaafl.htm".
            end.
            if lookup(lgr.lgr,"138,139,140") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaacfl.htm".
            end.
            if lookup(lgr.lgr,"143,144,145") > 0  then do:
                v-ifile = "/data/export/" + v-prefix + "aaacul.htm".
            end.

            output stream v-out to value(v-ofile).
            input from value(v-ifile).

            if caps(cif.type) = "B" and lookup(string(cif.cgr),"403,405,605,610,611") > 0 then do:
               v-ipsvidrus = "свидетельства о государственной регистрации " + cif.ref[8] + " от " + string(cif.expdt,"99.99.9999") + " г.".
               v-ipsvidkz = string(cif.expdt,"99.99.9999") + " жыл&#1171;ы " + cif.ref[8] + " мемлекеттік тіркеу туралы ку&#1241;лік".
               v-binrus = "ИИН".
               v-binkz = "ЖСН".
            end. else do:
               v-ipsvidrus = "Устава".
               v-ipsvidkz = "Жар&#1171;ы".
               v-binrus = "БИН".
               v-binkz = "БСН".
            end.


            repeat:
               import unformatted v-str.
               v-str = trim(v-str).

               run defval(aaa.opnamt, aaa.crc, output v-rval, output v-kval).

               find last acvolt where acvolt.aaa = aaa.aaa no-lock no-error.

               if lookup(lgr.lgr,"478,479,480,481,482,483") > 0  then do:
                  run Sm-vrd(integer(acvolt.x4), output v-acla).
                  run Sm-vrd-kzopti(integer(acvolt.x4), output v-kacla).
                  run defddmm(integer(acvolt.x4), output v-rdd, output v-kdd, output v-rmm, output v-kmm).
                  if acvolt.sts = "d" then do:
                      v-rddmm = v-rdd.
                      v-kddmm = v-kdd.
                  end.
                  else do:
                      v-rddmm = v-rmm.
                      v-kddmm = v-kmm.
                  end.
               end. else do:
                  run Sm-vrd(aaa.cla, output v-acla).
                  run Sm-vrd-kzopti(aaa.cla, output v-kacla).
                  run defddmm(aaa.cla, output v-rdd, output v-kdd, output v-rmm, output v-kmm).
                  v-rddmm = v-rmm.
                  v-kddmm = v-kmm.
               end.

               run Sm-vrd(aaa.opnamt, output v-sumopnam).
               run Sm-vrd-kzopti(aaa.opnamt, output v-ksumopnam).
               run Sm-vrd(lgr.tlimit[1], output v-rnost).
               run Sm-vrd-kzopti(lgr.tlimit[1], output v-knost).

               v-fo = cif.name.
               v-fo = replace (v-fo, " ", ",").
               v-fam =  entry(1,v-fo).
               v-nam = entry(2,v-fo).
               v-otch = entry(3,v-fo).

               repeat:
                 if v-stamp <> "" then do:
                     if v-str matches "*pkstamp*" then do:
                        v-str = replace (v-str, "pkstamp", v-stamp  ).
                        next.
                     end.
                 end.

                 if v-dogsgn <> "" then do:
                     if v-str matches "*pkdogsgn*" then do:
                        v-str = replace (v-str, "pkdogsgn", v-dogsgn  ).
                        next.
                     end.
                 end.

                 if v-str matches "*pustota*" then do:
                    v-str = replace (v-str, "pustota", "&nbsp;&nbsp;&nbsp;&nbsp;" ).
                    next.
                 end.
                 if v-dogsgn = "" then do:
                     if v-str matches "*rcity*" then do:
                        v-str = replace (v-str, "rcity", v-city).
                        next.
                     end.
                     if v-str matches "*kcity*" then do:
                        v-str = replace (v-str, "kcity", v-kcity).
                        next.
                     end.
                 end.
                 if v-dogsgn <> "" then do:
                     if v-str matches "*r1city*" then do:
                        v-str = replace (v-str, "r1city", "").
                        next.
                     end.
                     if v-str matches "*k1city*" then do:
                        v-str = replace (v-str, "k1city", "").
                        next.
                     end.
                 end.

                 if v-str matches "*r1city*" then do:
                    v-str = replace (v-str, "r1city", "Филиала в г. " + v-city).
                    next.
                 end.
                 if v-str matches "*k1city*" then do:
                    v-str = replace (v-str, "k1city", v-kcity + " &#1179;аласында&#1171;ы Филиал ").
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


                 find first codfr where codfr.codfr = "DKOSNKZ" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*kdover*" then do:
                        v-str = replace (v-str, "kdover", codfr.name[1] ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kdover*" then do:
                        v-str = replace (v-str, "kdover", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find first codfr where codfr.codfr = "DKOSN" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rdover*" then do:
                        v-str = replace (v-str, "rdover",  codfr.name[1] ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rdover*" then do:
                        v-str = replace (v-str, "rdover", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find first codfr where codfr.codfr = "DKKOGOKZ" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*kdolzhni*" then do:
                        v-str = replace (v-str, "kdolzhni", ENTRY(1,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                         if v-str matches "*kdolzhni*" then do:
                            v-str = replace (v-str, "kdolzhni", "&nbsp;&nbsp;" ).
                            next.
                         end.
                 end.
                 find first codfr where codfr.codfr = "DKKOGO" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rdolzhnr*" then do:
                        v-str = replace (v-str, "rdolzhnr", ENTRY(1,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rdolzhnr*" then do:
                        v-str = replace (v-str, "rdolzhnr", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.


                 find first codfr where codfr.codfr = "DKKOGOKZ" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*kfilchifi*" then do:
                        v-str = replace (v-str, "kfilchifi", ENTRY(2,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kfilchifi*" then do:
                        v-str = replace (v-str, "kfilchifi", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.
                 find first codfr where codfr.codfr = "DKKOGO" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rfilchifr*" then do:
                        v-str = replace (v-str, "rfilchifr", ENTRY(2,codfr.name[1],",")).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rfilchifr*" then do:
                        v-str = replace (v-str, "rfilchifr", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find first codfr where codfr.codfr = "DKDOLZHN" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rdolzhn*" then do:
                        v-str = replace (v-str, "rdolzhn",codfr.name[1]).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rdolzhn*" then do:
                        v-str = replace (v-str, "rdolzhn", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find first codfr where codfr.codfr = "DKPODP" and codfr.code = v-otvlico no-lock no-error.
                 if avail codfr then do:
                     if v-str matches "*rfiochif*" then do:
                        v-str = replace (v-str, "rfiochif",codfr.name[1]).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rfiochif*" then do:
                        v-str = replace (v-str, "rfiochif", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.


                 find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif
                     and sub-cod.d-cod = "clnchf" no-lock no-error.
                 if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                    v-tmpstr = "&nbsp;&nbsp;".
                    if v-str matches "*clnchif*" then do:
                        v-str = replace (v-str, "clnchif", v-tmpstr ).
                        next.
                    end.
                 end.
                 else do:
                     v-tmpstr = trim(sub-cod.rcode).
                     if v-str matches "*clnchif*" then do:
                        v-str = replace (v-str, "clnchif", v-tmpstr).
                        next.
                     end.
                 end.

                 find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif
                     and sub-cod.d-cod = "clnchf" no-lock no-error.
                 if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                    v-tmpstr = "&nbsp;&nbsp;".
                    if v-str matches "*sclnchf*" then do:
                        v-str = replace (v-str, "sclnchf", v-tmpstr ).
                        next.
                    end.
                 end.
                 else do:
                     v-tmpstr = trim(sub-cod.rcode).
                     v-tmpstr1 = v-tmpstr.
                     v-tmpstr1 = entry(1,v-tmpstr," ") + " " + SUBSTRING(entry(2,v-tmpstr," "),1,1) + "." + " " + SUBSTRING(entry(3,v-tmpstr," "),1,1) + "." no-error.
                     if v-str matches "*sclnchf*" then do:
                        v-str = replace (v-str, "sclnchf", v-tmpstr1 ).
                        next.
                     end.
                 end.

                 if caps(cif.type) = "B" and lookup(string(cif.cgr),"403,405,605,610,611") > 0 then do:
                     if v-str matches "*rclndlzh*" then do:
                        v-str = replace (v-str, "rclndlzh", cif.prefix ).
                        next.
                     end.
                 end.

                 v-tmpstr = "".
                 find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif
                     and sub-cod.d-cod = "clnchfd1" no-lock no-error.
                 if not avail sub-cod or sub-cod.ccode = "msc" or trim(sub-cod.rcode) = '' then do:
                     if v-str matches "*rclndlzh*" then do:
                        v-str = replace (v-str, "rclndlzh", v-tmpstr ).
                        next.
                     end.
                     if v-str matches "*rclnchfdlzh*" then do:
                        v-str = replace (v-str, "rclnchfdlzh", v-tmpstr ).
                        next.
                     end.
                     if v-str matches "*kclnchfdlzh*" then do:
                        v-str = replace (v-str, "kclnchfdlzh", v-tmpstr ).
                        next.
                     end.
                 end.
                 else do:
                     v-tmpstr = trim(sub-cod.rcode).
                     if v-str matches "*rclndlzh*" then do:
                        v-str = replace (v-str, "rclndlzh", v-tmpstr ).
                        next.
                     end.
                     v-tmpstr1 = v-tmpstr.
                     if TRIM(CAPS(v-tmpstr)) = "ДИРЕКТОР" then do: v-tmpstr = "Директора". v-tmpstr1 = "Директоры". end.
                     if TRIM(CAPS(v-tmpstr)) = "ГЛАВА КХ" then do: v-tmpstr = "Главы КХ". v-tmpstr1 = "Ш&#1178; басшысы". end.
                     if TRIM(CAPS(v-tmpstr)) = "ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ" then do: v-tmpstr = "Индивидуального предпринимателя". v-tmpstr1 = "Жеке к&#1241;сіпкер". end.
                     if caps(cif.type) = "B" and lookup(string(cif.cgr),"403,405,605,610,611") > 0 then do: v-tmpstr = "". v-tmpstr1 = "". end.

                     if v-str matches "*rclnchfdlzh*" then do:
                        v-str = replace (v-str, "rclnchfdlzh", trim(v-tmpstr) ).
                        next.
                     end.
                     if v-str matches "*kclnchfdlzh*" then do:
                        v-str = replace (v-str, "kclnchfdlzh", trim(v-tmpstr1) ).
                        next.
                     end.
                 end.

                 if v-str matches "*rbin*" then do:
                    v-str = replace (v-str, "rbin", v-binrus ).
                    next.
                 end.
                 if v-str matches "*kbin*" then do:
                    v-str = replace (v-str, "kbin", v-binkz ).
                    next.
                 end.


                 if v-str matches "*rustav*" then do:
                    v-str = replace (v-str, "rustav", v-ipsvidrus ).
                    next.
                 end.
                 if v-str matches "*kustav*" then do:
                    v-str = replace (v-str, "kustav", v-ipsvidkz ).
                    next.
                 end.

                 if v-str matches "*namecompany*" then do:
                    v-str = replace (v-str, "namecompany", trim(cif.name) ).
                    next.
                 end.

                 if v-str matches "*rfsobs*" then do:
                    v-str = replace (v-str, "rfsobs", cif.prefix ).
                    next.
                 end.
                 v-tmpstr = cif.prefix.
                 if trim(cif.prefix) = "ГУ" then v-tmpstr = "ММ".
                 if trim(cif.prefix) = "Учреждение" then v-tmpstr = "Мекеме".
                 if trim(cif.prefix) = "ПК" then v-tmpstr = "&#1256;К". /*в сокращении повтор :( */
                 if trim(cif.prefix) = "АО" then v-tmpstr = "А&#1178;".
                 if trim(cif.prefix) = "ТДО" then v-tmpstr = "&#1178;ЖС".
                 if trim(cif.prefix) = "ТОО" then v-tmpstr = "ЖШС".
                 if trim(cif.prefix) = "КД" then v-tmpstr = "КС".
                 if trim(cif.prefix) = "ПТ" then v-tmpstr = "ТС".
                 if trim(cif.prefix) = "РО" then v-tmpstr = "ДБ".
                 if trim(cif.prefix) = "ОФ" then v-tmpstr = "&#1178;&#1178;".
                 if trim(cif.prefix) = "ПК" then v-tmpstr = "ТК". /*в сокращении повтор :( */
                 if trim(cif.prefix) = "АО" then v-tmpstr = "А&#1178;".
                 if trim(cif.prefix) = "ОО" then v-tmpstr = "&#1178;Б".
                 if trim(cif.prefix) = "ГП" then v-tmpstr = "МК".
                 if trim(cif.prefix) = "ОТ" then v-tmpstr = "КС".
                 if trim(cif.prefix) = "ИП" then v-tmpstr = "ЖК".
                 if lookup(trim(cif.prefix),"КХ,К/Х,К/х") > 0 then v-tmpstr = "Ш&#1178;".
                 if lookup(trim(cif.prefix),"Частный нотариус,ЧН") > 0 then v-tmpstr = "ЖН".
                 if trim(cif.prefix) = "ЧП" then v-tmpstr = "ЖК".
                 if trim(cif.prefix) = "НОТАРИУС" then v-tmpstr = "НОТАРИУС".
                 if lookup(trim(cif.prefix),"Частное учреждение,ЧУ") > 0 then v-tmpstr = "ЖМ".
                 if trim(cif.prefix) = "ЗАО" then v-tmpstr = "ЖА&#1178;".


                 if trim(cif.prefix) = "Посольство" then v-tmpstr = "Елшілік".
                 if trim(cif.prefix) = "ОАО" then v-tmpstr = "АА&#1178;".
                 if trim(cif.prefix) = "БПГ" then v-tmpstr = "МБ&#1178;".
                 if trim(cif.prefix) = "ПС" then v-tmpstr = "&#1256;БК".
                 if trim(cif.prefix) = "КТ" then v-tmpstr = "КС".
                 if trim(cif.prefix) = "НАО" then v-tmpstr = "КА&#1178;".
                 if trim(cif.prefix) = "Представительство" then v-tmpstr = "&#1256;кілдік".
                 if trim(cif.prefix) = "ДКУ" then v-tmpstr = "БНМ".
                 if trim(cif.prefix) = "СП" then v-tmpstr = "БК".
                 if trim(cif.prefix) = "ОФ" then v-tmpstr = "ОФ".
                 if trim(cif.prefix) = "ТДО" then v-tmpstr = "&#1178;ЖС".
                 if trim(cif.prefix) = "НП" then v-tmpstr = "НП".
                 if trim(cif.prefix) = "СПК" then v-tmpstr = "АТК".
                 if trim(cif.prefix) = "КА" then v-tmpstr = "АК".
                 if trim(cif.prefix) = "КСК" then v-tmpstr = "ЖПК".
                 if trim(cif.prefix) = "КСП" then v-tmpstr = "ЖЖК".
                 if trim(cif.prefix) = "ЖК" then v-tmpstr = "ТК".
                 if trim(cif.prefix) = "ЖСК" then v-tmpstr = "Т&#1178;К".
                 if trim(cif.prefix) = "Ассоциация" then v-tmpstr = "Ассоциация".
                 if trim(cif.prefix) = "" then v-tmpstr = "".
                 if trim(cif.prefix) = "Компания" then v-tmpstr = "Компаниясы".
                 if trim(cif.prefix) = "КОМПАНИЯ" then v-tmpstr = "КОМПАНИЯСЫ".
/*

*/



                 if v-str matches "*kfsobs*" then do:
                    v-str = replace (v-str, "kfsobs", v-tmpstr ).
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
                 if v-nam <> "" then do:
                     if v-str matches "*snameofcln*" then do:
                        v-str = replace (v-str, "snameofcln", SUBSTRING(v-nam,1,1) + ".").
                        next.
                     end.
                 end. else do:
                     if v-str matches "*snameofcln*" then do:
                        v-str = replace (v-str, "snameofcln", " ").
                        next.
                     end.
                 end.

                 if v-str matches "*othestvoclienta*" then do:
                    v-str = replace (v-str, "othestvoclienta", v-otch ).
                    next.
                 end.

                 if v-otch <> "" then do:
                     if v-str matches "*sothestvocln*" then do:
                        v-str = replace (v-str, "sothestvocln", SUBSTRING(v-otch,1,1) + "." ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*sothestvocln*" then do:
                        v-str = replace (v-str, "sothestvocln", " " ).
                        next.
                     end.
                 end.

                 if v-str matches "*wjfnfkrfrj*" then do:
                    v-str = replace (v-str, "wjfnfkrfrj", string(aaa.opnamt) + " (" + v-sumopnam + ")").
                    next.
                 end.

                 if v-str matches "*kvclsm*" then do:
                    v-str = replace (v-str, "kvclsm", string(aaa.opnamt) + " (" + v-ksumopnam + ")").
                    next.
                 end.

                 if v-str matches "*kvaluta*" then do:
                    v-str = replace (v-str, "kvaluta", v-kval) .
                    next.
                 end.

                 if v-str matches "*rvaluta*" then do:
                    v-str = replace (v-str, "rvaluta", v-rval) .
                    next.
                 end.

                 if v-str matches "*valutavklada*" then do:
                    v-str = replace (v-str, "valutavklada", crc.des) .
                    next.
                 end.

                 if lookup(lgr.lgr,"478,479,480,481,482,483") > 0  then do:
                     if v-str matches "*kolvomes*" then do:
                        v-str = replace (v-str, "kolvomes", string(integer(acvolt.x4)) + " (" + v-acla + ") " + v-rddmm + " "  ).
                        next.
                     end.
                     if v-str matches "*kklasvka*" then do:
                        v-str = replace (v-str, "kklasvka", string(integer(acvolt.x4)) + " (" + v-kacla + ") " + v-kddmm + " "  ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kolvomes*" then do:
                        v-str = replace (v-str, "kolvomes", string(aaa.cla) + " (" + v-acla + ") " + v-rddmm + " " ).
                        next.
                     end.
                     if v-str matches "*kklasvka*" then do:
                        v-str = replace (v-str, "kklasvka", string(aaa.cla) + " (" + v-kacla + ") " + v-kddmm + " "  ).
                        next.
                     end.
                 end.


                 if v-str matches "*rclaperiod*" then do:
                    v-str = replace (v-str, "rclaperiod", vr-period).
                    next.
                 end.
                 if v-str matches "*kclaperiod*" then do:
                    v-str = replace (v-str, "kclaperiod", vk-period).
                    next.
                 end.


                 if v-str matches "*iikclienta*" then do:
                    v-str = replace (v-str, "iikclienta", aaa.aaa ).
                    next.
                 end.

                 if v-str matches "*dstavka*" then do:
                   v-str = replace (v-str, "dstavka", string(aaa.rate,">9.99") ).
                   next.
                 end.
                 if v-str matches "*efstavka*" then do:
                   v-str = replace (v-str, "efstavka", string(ROUND(decimal(acvolt.x2),1),">9.9")).
                   next.
                 end.

                 if v-str matches "*knost*" then do:
                    v-str = replace (v-str, "knost", string(lgr.tlimit[1]) + " (" + v-knost + ")").
                    next.
                 end.
                 if v-str matches "*rnost*" then do:
                    v-str = replace (v-str, "rnost", string(lgr.tlimit[1]) + " (" + v-rnost + ")").
                    next.
                 end.

                 if v-str matches "*$code$*" then do:
                    v-str = replace (v-str, "$code$", cif.attn ).
                    next.
                 end.
                 if v-str matches "*$cword$*" then do:
                    find first pcstaff0 where pcstaff0.cif = cif.cif and pcstaff0.aaa = aaa.aaa no-lock no-error.
                    if avail pcstaff0 then v-str = replace (v-str, "$cword$", pcstaff0.cword ).
                    else v-str = replace (v-str, "$cword", " " ).
                    next.
                 end.
                 if aaa.crc = 1 then do:
                    v-tmpstr = "в Тенге".
                    v-tmpstr1 = "Те&#1226;геде".
                 end.
                 if aaa.crc = 2 then do:
                    v-tmpstr = "в Долларах США".
                    v-tmpstr1 = "А&#1178;Ш долларында".
                 end.
                 if aaa.crc = 3 then do:
                    v-tmpstr = "в Евро".
                    v-tmpstr1 = "Еурода".
                 end.
                 if aaa.crc = 4 then do:
                    v-tmpstr = "в Российских рублях".
                    v-tmpstr1 = "Ресей рублiнде".
                 end.
                 if aaa.crc = 6 then do:
                    v-tmpstr = "в Фунтах стерлингах".
                    v-tmpstr1 = "Фунт стерлингте".
                 end.
                 if aaa.crc = 7 then do:
                    v-tmpstr = "В Шведских кронах".
                    v-tmpstr1 = "Шведтік кронда".
                 end.
                 if aaa.crc = 8 then do:
                    v-tmpstr = "В Австралийских долларах".
                    v-tmpstr1 = "Австралиялы&#1179; долларда".
                 end.
                 if aaa.crc = 9 then do:
                    v-tmpstr = "В Швейцарских франках".
                    v-tmpstr1 = "Швейцариялы&#1179; франкте".
                 end.

                 if v-str matches "*rvalr*" then do:
                    v-str = replace (v-str, "rvalr", v-tmpstr ).
                    next.
                 end.
                 if v-str matches "*kvalk*" then do:
                    v-str = replace (v-str, "kvalk", v-tmpstr1 ).
                    next.
                 end.
                 v-tmpstrlist = "".
                 v-tmpstrlist1 = "".
                 do i =  1 to NUM-ENTRIES(v-acclist):
                    if v-tmpstrlist <> "" then v-tmpstrlist = v-tmpstrlist + " <br> ".
                    if v-tmpstrlist1 <> "" then v-tmpstrlist1 = v-tmpstrlist1 + " <br> ".

                    find first buf-aaa where buf-aaa.aaa = ENTRY(i,v-acclist) no-lock no-error.
                    if buf-aaa.crc = 1 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Тенге, номер Счета (ИИК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 2 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Долларах США, номер Счета (ИИК):&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 3 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Евро, номер Счёта (ИИК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 4 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Российских рублях, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 6 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Фунтах стерлингах, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 7 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Шведских кронах, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 8 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Австралийских долларах, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 9 then v-tmpstrlist = v-tmpstrlist + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;в Швейцарских франках, номер Счета (ИИК):&nbsp;" + buf-aaa.aaa.

                    if buf-aaa.crc = 1 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Те&#1226;геде, Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 2 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;А&#1178;Ш долларында, Шот н&#1257;мірі (ЖСК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 3 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Еурода, Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 4 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Ресей рублінде, Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 6 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Фунт стерлингте , Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 7 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Шведтік кронда , Шот н&#1257;мірі (ЖСК):&nbsp;&nbsp;&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 8 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Австралиялы&#1179; долларда , Шот н&#1257;мірі (ЖСК):&nbsp;" + buf-aaa.aaa.
                    if buf-aaa.crc = 9 then v-tmpstrlist1 = v-tmpstrlist1 + "&nbsp;&nbsp;" + string(i) + ".&nbsp;&nbsp;Швейцариялы&#1179; франкте , Шот н&#1257;мірі (ЖСК):&nbsp;" + buf-aaa.aaa.
                 end.
                 if v-str matches "*raaalist*" then do:
                    v-str = replace (v-str, "raaalist", v-tmpstrlist ).
                    next.
                 end.
                 if v-str matches "*kaaalist*" then do:
                    v-str = replace (v-str, "kaaalist", v-tmpstrlist1 ).
                    next.
                 end.

                 v-tmpstr = cif.addr[1].
                 v-tmpstr = replace (v-tmpstr, ",", ", " ).
                 if v-str matches "*adresclienta*" then do:
                    v-str = replace (v-str, "adresclienta", v-tmpstr ).
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

                 if NUM-ENTRIES(cif.pss, " ") > 0 then do:
                     if v-str matches "*udosn*" then do:
                        v-str = replace (v-str, "udosn", ENTRY(1,cif.pss," ") ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*udosn*" then do:
                        v-str = replace (v-str, "udosn", "&nbsp;" ).
                        next.
                     end.
                 end.

                 if NUM-ENTRIES(cif.pss, " ") > 3 then do:
                     if v-str matches "*rkemvid*" then do:
                        v-str = replace (v-str, "rkemvid", ENTRY(3,cif.pss," ") ).
                        next.
                     end.
                     if v-str matches "*kkemvid*" then do:
                        v-tmpstr =  ENTRY(3,cif.pss," ").
                        if  TRIM(CAPS(v-tmpstr)) = "МВД" then v-str = replace (v-str, "kkemvid", "IIM" ). else
                            if  TRIM(CAPS(v-tmpstr)) = "МЮ" then v-str = replace (v-str, "kkemvid", "&#1240;М" ). else
                                v-str = replace (v-str, "kkemvid", v-tmpstr ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*rkemvid*" then do:
                        v-str = replace (v-str, "rkemvid", "&nbsp;" ).
                        next.
                     end.
                     if v-str matches "*kkemvid*" then do:
                        v-str = replace (v-str, "kkemvid", "&nbsp;" ).
                        next.
                     end.
                 end.

                 if NUM-ENTRIES(cif.pss, " ") > 1 then do:
                     if v-str matches "*dtvid*" then do:
                        v-tmpstr = ENTRY(2,cif.pss," ").
                        if length(v-tmpstr) > 8 then do:
                           v-tmpstr = replace (v-tmpstr, "/", "." ).
                        end.
                        if length(v-tmpstr) = 8 then do:
                           v-tmpstr = SUBSTRING (v-tmpstr, 1, 2) + "." + SUBSTRING (v-tmpstr, 3, 2) + "." + SUBSTRING (v-tmpstr, 5, 4).
                        end.
                        v-str = replace (v-str, "dtvid", v-tmpstr ).
                     end.
                 end. else do:
                     if v-str matches "*dtvid*" then do:
                        v-str = replace (v-str, "dtvid", "&nbsp;&nbsp;" ).
                        next.
                     end.
                 end.

                 find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
                 if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" and aaa.sta <> "C" then do:
                    if v-str matches "*rcity*" then do:
                       v-str = replace (v-str, "rcity", ENTRY(2,ENTRY(1,trim(ppoint.info[5])),".") ).
                       next.
                    end.
                    if v-str matches "*kcity*" then do:
                       v-str = replace (v-str, "kcity", ENTRY(1,ENTRY(1,trim(ppoint.info[6]))," ") ).
                       next.
                    end.

                    if v-str matches "*raddrbank*" then do:
                       v-str = replace (v-str, "raddrbank", trim(ppoint.info[5]) ).
                       next.
                    end.
                    if v-str matches "*telbank*" then do:
                       v-str = replace (v-str, "telbank", trim(ppoint.info[7]) ).
                       next.
                    end.
                    if v-str matches "*kaddrbank*" then do:
                       v-str = replace (v-str, "kaddrbank", trim(ppoint.info[6]) ).
                       next.
                    end.
                 end.

                 find first cmp no-lock no-error.
                 if avail cmp then do:
                     if v-str matches "*raddrbank*" then do:
                        v-str = replace (v-str, "raddrbank", cmp.addr[1] ).
                        next.
                     end.
                     if v-str matches "*telbank*" then do:
                        v-str = replace (v-str, "telbank", cmp.tel ).
                        next.
                     end.
                     if v-str matches "*rnnbank*" then do:
                        v-str = replace (v-str, "rnnbank", cmp.addr[2] ).
                        next.
                     end.
                 end.
                 v-kazaddr = "".
                 find sysc where sysc.sysc = "bnkadr" no-lock no-error.
                 if avail sysc then do:
                   v-kazaddr = entry(11, sysc.chval, "|") no-error.
                 end.
                 if v-kazaddr <> "" then do:
                     if v-str matches "*kaddrbank*" then do:
                        v-str = replace (v-str, "kaddrbank", v-kazaddr ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*kaddrbank*" then do:
                        v-str = replace (v-str, "kaddrbank", "&nbsp;&nbsp;" ).
                        next.
                     end.
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

                 find sysc where sysc.sysc = "bnkbin" no-lock no-error.
                 if avail sysc then do:
                     if v-str matches "*binbank*" then do:
                        v-str = replace (v-str, "binbank", sysc.chval ).
                        next.
                     end.
                 end. else do:
                     if v-str matches "*binbank*" then do:
                        v-str = replace (v-str, "binbank", "&nbsp;&nbsp;" ).
                        next.
                     end.
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

                 leave.
               end.
             put stream v-out unformatted v-str skip.
            end.


            input close.
            output stream v-out close.
            unix silent cptunkoi value(v-ofile) winword.
        end. /*lookup(lgr.lgr,"A22,A23,A24") > 0 */







if lookup(lgr.lgr,"B15,B16,B17,B18,B19,B20,B09,B10,B11,B01,B02,B03,B04,B05,B06,B07,B08,A38,A39,A40,A22,A23,A24,A01,A02,A03,A04,A05,A06,246,478,479,480,481,482,483,518,519,520,151,153,171,157,176,152,154,172,158,177,173,175,174,202,204,222,208,138,139,140,143,144,145") = 0 then do:
do:
if lookup(string(lgr.feensf),"1,2,3,4,5,6,7") <> 0  then do:

/*Первая часть для всех договоров*/


   v-ofile = "ofile.htm" .

if bmm.chval = "TXB00" then
   v-ifile = "/data/export/docum.htm".
else
   v-ifile = "/data/export/op_docum.htm".


/*
if bmm.chval = "TXB00" then
   v-ifile = "docum.htm".
else
   v-ifile = "op_docum.htm".
*/

/*Метрошка*/
if lgr.feensf = 7 then do:
   if bmm.chval = "TXB00" then
      v-ifile = "/data/export/metroshka1.htm".
   else
      v-ifile = "/data/export/op_metroshka1.htm".
end.



/*Первая часть договоров*/
   output stream v-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:
           if v-str matches "*rchs*" then do:
              v-str = replace (v-str, "rchs", string(day(aaa.regdt)) ).
              next.
           end.
           if v-str matches "*kmes*" then do:
              v-str = replace (v-str, "kmes", vk-mes).
              next.
           end.
           if v-str matches "*rcity*" then do:
              v-str = replace (v-str, "rcity", v-city).
              next.
           end.
           if v-str matches "*rmes*" then do:

              v-str = replace (v-str, "rmes", vr-mes).
              next.
           end.
           if v-str matches "*dirdeprt*" then do:
              v-str = replace (v-str, "dirdeprt", string(v-podp)).
              next.
           end.


           leave.
         end.

      put stream v-out unformatted v-str skip.
      end.
   input close.
   output stream v-out close.
   unix silent cptwin value(v-ofile) winword.

/*вторая часть договоров*/

             if aaa.crc = 1 then v-rastr = "10".
             if aaa.crc = 2 then v-rastr = "5".
             if aaa.crc = 3 then v-rastr = "4".



  run Sm-vrd(aaa.cla, output v-acla).
  run Sm-vrd-kzopti(aaa.cla, output v-kacla).

  run Sm-vrd(aaa.opnamt, output v-sumopnam).
  run Sm-vrd-kzopti(aaa.opnamt, output v-ksumopnam).

  find last acvolt where acvolt.aaa = aaa.aaa no-lock no-error.
/*  v-sumopnam = string(aaa.opnamt) + " (" + v-sumopnam + ")"  . */
  v-fo = cif.name.
  v-fo = replace (v-fo, " ", ",").
  v-fam =  entry(1,v-fo).
  v-nam = entry(2,v-fo).
  v-otch = entry(3,v-fo).


if bmm.chval = "TXB00" then do:
   if lgr.feensf =  1 then do:    v-ifile = "/data/export/standart.htm".  end.
   if lgr.feensf =  2 then do:    v-ifile = "/data/export/classic.htm".  end.
   if lgr.feensf =  3 then do:    v-ifile = "/data/export/luks.htm".  end.
   if lgr.feensf =  6 then do:    v-ifile = "/data/export/luks.htm".  end.
   if lgr.feensf =  4 then do:    v-ifile = "/data/export/vip.htm".  end.
   if lgr.feensf =  5 then do:    v-ifile = "/data/export/superluks.htm".  end.
end.
else
do:
   if lgr.feensf =  1 then do:    v-ifile = "/data/export/op_standart.htm".  end.
   if lgr.feensf =  2 then do:    v-ifile = "/data/export/op_classic.htm".  end.
   if lgr.feensf =  3 then do:    v-ifile = "/data/export/op_luks.htm".  end.
   if lgr.feensf =  6 then do:    v-ifile = "/data/export/op_luks.htm".  end.
   if lgr.feensf =  4 then do:    v-ifile = "/data/export/op_vip.htm".  end.
   if lgr.feensf =  5 then do:    v-ifile = "/data/export/op_superluks.htm".  end.
end.


/*Метрошка*/
if lgr.feensf = 7 then do:
    if bmm.chval = "TXB00" then do:
       v-ifile = "/data/export/mtroshka2.htm".
    end.
    else do:
       v-ifile = "/data/export/op_mtroshka2.htm".
    end.
end.

/*Пенсионный*/
if lgr.feensf = 3 and  not lgr.des   begins "Метро-ЛЮКС" then do:
    if bmm.chval = "TXB00" then do:
       v-ifile = "/data/export/pensionii.htm".
    end.
    else do:
       v-ifile = "/data/export/op_pensionii.htm".
    end.
end.


   v-ofile = "part2.htm" .
   output stream v-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:



           if v-str matches "*perrsent*" then do:
              v-str = replace (v-str, "perrsent", v-rastr).
              next.
           end.

           if v-str matches "*familia*" then do:
              v-str = replace (v-str, "familia", v-fam).
              next.
           end.
           if v-str matches "*nameofclient*" then do:
              v-str = replace (v-str, "nameofclient", v-nam).
              next.
           end.
           if v-str matches "*othestvoclienta*" then do:
              v-str = replace (v-str, "othestvoclienta", v-otch).
              next.
           end.
           if v-str matches "*rnnclienta*" then do:
              v-str = replace (v-str, "rnnclienta", cif.jss ).
              next.
           end.

           if v-str matches "*adresclienta*" then do:
/*              v-str = replace (v-str, "adresclienta", cif.addr[1] + ' ' + cif.addr[2]).*/
                v-str = replace (v-str, "adresclienta", cif.addr[1]).
              next.
           end.
           if v-str matches "*yelclienta*" then do:
              v-str = replace (v-str, "yelclienta", cif.tel).
              next.
           end.
           if v-str matches "*iikclienta*" then do:
              v-str = replace (v-str, "iikclienta", aaa.aaa).
              next.
           end.
           if v-str matches "*wjfnfkrfrj*" then do:
              v-str = replace (v-str, "wjfnfkrfrj", string(aaa.opnamt) + " (" + v-sumopnam + ")").
              next.
           end.

           if v-str matches "*kvclsm*" then do:
              v-str = replace (v-str, "kvclsm", string(aaa.opnamt) + " (" + v-ksumopnam + ")").
              next.
           end.

           if v-str matches "*valutavklada*" then do:
              v-str = replace (v-str, "valutavklada", crc.des).
              next.
           end.
           if v-str matches "*datav1*" then do:
              v-str = replace (v-str, "datav1", string(aaa.regdt)).
              next.
           end.
           if v-str matches "*datav2*" then do:
              v-str = replace (v-str, "datav2", string(aaa.expdt)).
              next.
           end.

           if v-str matches "*kolvomes*" then do:
              v-str = replace (v-str, "kolvomes", string(aaa.cla) + " (" + v-acla + ")" ).
              next.
           end.
           if v-str matches "*kklasvka*" then do:
              v-str = replace (v-str, "kklasvka", string(aaa.cla) + " (" + v-kacla + ")" ).
              next.
           end.


           if v-str matches "*kmeskl*" then do:
              v-str = replace (v-str, "kmeskl", string(aaa.cla) + " ()" ).
              next.
           end.


           if v-str matches "*dirdeprt*" then do:
              v-str = replace (v-str, "dirdeprt", string(v-podp)).
              next.
           end.

           if v-str matches "*lukstavka*" then do:
              v-str = replace (v-str, "lukstavka", string("10")).
              next.
           end.

/*Данные филиала*/
 if v-str matches "*danniefil*" then do:
    v-str = replace (v-str, "danniefil", v-bickfiliala).
    next.
 end.


 if v-str matches "*bickfilialakz*" then do:
    v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
    next.
 end.



           if v-str matches "*dstavka*" then do:
              v-str = replace (v-str, "dstavka", string(aaa.rate)).
              next.
           end.
           if v-str matches "*efstavka*" then do:
              v-str = replace (v-str, "efstavka", acvolt.x2).
              next.
           end.
           leave.
         end.

      put stream v-out unformatted v-str skip.
      end.
   input close.
   output stream v-out close.
   unix silent cptwin value(v-ofile) winword.
    message  "  ВНИМАНИЕ! "
    skip(5) "   ПРОВЕРЬТЕ ТЕКСТ ДОГОВОРА!     "
    skip "      При обнаружении ошибок сообщите в ДИТ.    "
    skip(5)  view-as alert-box question buttons ok title "" .

end.





      def var v-sys as char.
      find sysc where sysc.sysc = 'VC-AGR' no-lock no-error.
      v-sys = sysc.chval.
/*      if lookup(string(lgr.lgr),v-sys) <> 0  then do: */
       if lookup (lgr.lgr, sysc.chval) <> 0 or   lookup (lgr.lgr, "247,248") <> 0   then do:


             find last bmm where bmm.sysc = "OURBNK" no-lock no-error.
             v-ofile = "contract.htm".
             if lgr.tlev = 2 then do: /* физ лицо */

             v-ofile = "ofile.htm" .

/*             if bmm.chval = "TXB00" then
                 v-ifile = "/data/export/teksof.htm".
             else
                 v-ifile = "/data/export/teksfil.htm". */
             if bmm.chval = "TXB00" then do:
                 if lgr.lgr = "247" or lgr.lgr = "248" then
                    v-ifile = "/data/export/kassanovaof.htm".
                 else
                    v-ifile = "/data/export/teksof.htm".
             end.
             else
             do:
                 if lgr.lgr = "247" or lgr.lgr = "248" then
                     v-ifile = "/data/export/kassanovafil.htm".
                 else
                     v-ifile = "/data/export/teksfil.htm".
             end.


              output stream v-out to value(v-ofile).
              input from value(v-ifile).
              repeat:
                    import unformatted v-str.
                    v-str = trim(v-str).
                    repeat:
                        if v-str matches "*citiiii*" then do:
                           v-str = replace (v-str, "citiiii", v-city).
                           next.
                        end.
                        if v-str matches "*shsl*" then do:
                           v-str = replace (v-str, "shsl", string(day(g-today)) ).
                           next.
                        end.
                        if v-str matches "*rvyears*" then do:
                           v-str = replace (v-str, "rvyears", string(year(g-today)) ).
                           next.
                        end.

                        if v-str matches "*msmsms*" then do:
                           v-str = replace (v-str, "msmsms", string(vr-mes) ).
                           next.
                        end.
                        if v-str matches "*mskzmskzms*" then do:
                           v-str = replace (v-str, "mskzmskzms", string(vk-mes)).
                           next.
                        end.
                        if v-str matches "*fioclienta*" then do:
                           v-str = replace (v-str, "fioclienta", string(cif.name) ).
                           next.
                        end.
                        if v-str matches "*iikname*" then do:
                           v-str = replace (v-str, "iikname", string(aaa.aaa)).
                           next.
                        end.
                        if v-str matches "*valutasheta*" then do:
                           v-str = replace (v-str, "valutasheta", string(crc.des) ).
                           next.
                        end.
                        if v-str matches "*datav1*" then do:
                           v-str = replace (v-str, "datav1", string(aaa.regdt) ).
                           next.
                        end.
                        if v-str matches "*dirdeprt*" then do:
                           v-str = replace (v-str, "dirdeprt", string(v-podp) ).
                           next.
                        end.
                        if v-str matches "*adresclienta*" then do:
/*                           v-str = replace (v-str, "adresclienta", cif.addr[1] + ' ' + cif.addr[2]). */
                           v-str = replace (v-str, "adresclienta", cif.addr[1]).
                           next.
                        end.
                        if v-str matches "*passportclienta*" then do:
                           v-str = replace (v-str, "passportclienta", string(cif.pss) ).
                           next.
                        end.
                        if v-str matches "*telclienta*" then do:
                           v-str = replace (v-str, "telclienta", cif.tel ).
                           next.
                        end.
                        if v-str matches "*faxclienta*" then do:
                           v-str = replace (v-str, "faxclienta", "").
                           next.
                        end.
                        if v-str matches "*rnnclienta*" then do:
                           v-str = replace (v-str, "rnnclienta", string(cif.jss) ).
                           next.
                        end.
                        if v-str matches "*iikclienta*" then do:
                           v-str = replace (v-str, "iikclienta", aaa.aaa ).
                           next.
                        end.
                       /*Данные филиала*/
                        if v-str matches "*danniefil*" then do:
                           v-str = replace (v-str, "danniefil", v-bickfiliala).
                           next.
                        end.
                        if v-str matches "*bickfilialakz*" then do:
                           v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
                           next.
                        end.
                        leave.
                     end.
                     put stream v-out unformatted v-str skip.
                end.
                input close.
                output stream v-out close.
                unix silent cptunkoi value(v-ofile) winword.
                message  "  ВНИМАНИЕ! "
                skip(5) "   ПРОВЕРЬТЕ ТЕКСТ ДОГОВОРА!  !"
                skip "      При обнаружении ошибок сообщите в ДИТ.    "
                skip(5)  view-as alert-box question buttons ok title "" .



   end.

      end.

end.





end. /* if lookup(lgr.lgr,"A22,A23,A24,A01,A02,A03,A04,A05,A06,246,478,479,480,481,482,483,518,519,520,
                                                151,153,171,157,176,152,154,172,158,177,173,175,174,202,204,222,208") = 0*/




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


procedure defdts1:
def input parameter p-rdt as date.
def input parameter p-edt as date.
def output parameter p-datastr as char.
def output parameter p-datastrkz as char.

def var v-monthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

def var v-monthnamekz1 as char init
   "&#1179;а&#1187;тарынан,а&#1179;панынан,наурызынан,с&#1241;уiрiнен,мамырынан,маусымынан,шiлдесінен,тамызынан,&#1179;ырк&#1199;йегінен,
   &#1179;азанынан,&#1179;арашасынан,желто&#1179;санынан".
def var v-monthnamekz2 as char init
   "&#1179;а&#1187;тарына,а&#1179;панына,наурызына,с&#1241;уiріне,мамырына,маусымына,шiлдесіне,тамызына,
    &#1179;ырк&#1199;йегіне,&#1179;азанына,&#1179;арашасына,желто&#1179;санына".

p-datastr = "c «" + string(day(p-rdt),"99") + "» " + entry(month(p-rdt), v-monthname)  + " " + string(year(p-rdt)) +
       " г. по «" + string(day(p-edt),"99") + "» " + entry(month(p-edt), v-monthname)  + " " + string(year(p-edt)) + " г.".

p-datastrkz = string(year(p-rdt)) + " ж. «" + string(day(p-rdt),"99") + "» " + entry(month(p-rdt), v-monthnamekz1) + " " +
              string(year(p-edt)) + " ж. «" + string(day(p-edt),"99") + "» " + entry(month(p-edt), v-monthnamekz2) + " дейін".

end.


procedure defval:
def input parameter p-sum as decimal.
def input parameter p-crc as integer.
def output parameter p-valrus as char.
def output parameter p-valkz as char.

def buffer buf-crc for crc.

def var nEd  as decimal.
def var nDec as decimal.

def var s as char.
def var s1 as char.

find first buf-crc where buf-crc.crc = p-crc no-lock no-error.

s = buf-crc.deskz[3].
s1 = buf-crc.deskz[2].


nEd  = p-sum modulo 10.
nDec = p-sum modulo 100.


if (nDec >= 11 and nDec <= 14) or (nEd >= 5 and nEd <= 9) or (nEd = 0) then do:
   p-valrus = entry(3, s).
   p-valkz = entry(3, s1).
end.
else if (nEd = 1) then do:
        p-valrus = entry(1, s).
        p-valkz = entry(1, s1).
     end.
     else do:
        p-valrus = entry(2, s).
        p-valkz = entry(2, s1).
     end.
end.


procedure defddmm:
def input parameter p-count as integer.
def output parameter p-ddrus as char.
def output parameter p-ddkz as char.
def output parameter p-mmrus as char.
def output parameter p-mmkz as char.


def var nEd  as decimal.
def var nDec as decimal.

def var mm as char.
def var mm1 as char.
def var dd as char.
def var dd1 as char.


mm = "ай,ай,ай".
mm1 = "месяц,месяца,месяцев".

dd = "к&#1199;н,к&#1199;н,к&#1199;н".
dd1 = "день,дня,дней".



nEd  = p-count modulo 10.
nDec = p-count modulo 100.


if (nDec >= 11 and nDec <= 14) or (nEd >= 5 and nEd <= 9) or (nEd = 0) then do:
   p-ddrus = entry(3, dd1).
   p-ddkz = entry(3, dd).
   p-mmrus = entry(3, mm1).
   p-mmkz = entry(3, mm).
end.
else if (nEd = 1) then do:
       p-ddrus = entry(1, dd1).
       p-ddkz = entry(1, dd).
       p-mmrus = entry(1, mm1).
       p-mmkz = entry(1, mm).
     end.
     else do:
       p-ddrus = entry(2, dd1).
       p-ddkz = entry(2, dd).
       p-mmrus = entry(2, mm1).
       p-mmkz = entry(2, mm).
     end.
end.