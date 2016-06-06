/* printplat2.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание - Печать платежных поручений
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
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        06.03.2012 damir.
        07.03.2012 damir - добавлено имя руководителя из справочника...
        14.03.2012 damir - подредактировал шаблон.
        11.09.2012 damir - Тестирование ИИН/БИН.
        26.12.2012 damir - Внедрено Т.З. 1624.
        30.09.2013 damir - Внедрено Т.З. № 1513,1648.
        04.10.2013 damir - Перекомпиляция, связанная с изменениями 30.09.2013.
        25.11.2013 damir - Внедрено Т.З. № 2219.
*/

/*ВНИМАНИЕ!!!*/
/*{printplat2.i} вызывается программами prtppp.p;extract.p*/

def var v-ifileinput as char init "/data/export/paymentordnew.htm". /*Шаблон платежных поручений*/

def buffer b-sub-cod for sub-cod.

if avail cif then find b-sub-cod where b-sub-cod.sub = "cln" and b-sub-cod.acc = cif.cif and b-sub-cod.d-cod = "clnbk" and b-sub-cod.ccode = "mainbk" no-lock no-error.

input from value(v-ifileinput).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*datetrx*" then do:
            v-str = replace (v-str,"datetrx",string(remtrz.valdt1,'99/99/9999')).
            next.
        end.
        if v-str matches "*timetrx*" then do:
            v-str = replace (v-str,"timetrx",string(if remtrz.rtim <> 0 then remtrz.rtim else time,'HH:MM:SS')).
            next.
        end.
        if v-str matches "*filalnametrx*" then do:
            v-str = replace (v-str,"filalnametrx",cmp.name).
            next.
        end.
        if v-str matches "*pldate*" then do:
            if remtrz.valdt1 <> ? then v-str = replace (v-str,"pldate",string(remtrz.valdt1,'99/99/9999')).
            else v-str = replace (v-str,"pldate","").
            next.
        end.
        if v-str matches "*numpl*" then do:
            if trim(substr(remtrz.sqn,19,8)) <> "" then v-str = replace (v-str,"numpl",trim(substr(remtrz.sqn,19,8)) + "(" + remtrz.remtrz + ")").
            else if remtrz.remtrz <> "" then v-str = replace (v-str,"numpl",trim(remtrz.remtrz)).
            else v-str = replace (v-str,"numpl","").
            next.
        end.
        if v-str matches "*kod*" then do:
            if v-plars <> "" then v-str = replace (v-str,"kod",trim(v-plars)).
            else v-str = replace (v-str,"kod","").
            next.
        end.
        if v-str matches "*nadpisone*" then do:
            if remtrz.source = 'IBH'  then v-str = replace (v-str,"nadpisone","Проведено по системе").
            else v-str = replace (v-str,"nadpisone","").
            next.
        end.
        if v-str matches "*nadpistwo*" then do:
            if remtrz.source = 'IBH'  then v-str = replace (v-str,"nadpistwo","Интернет Банкинг").
            else v-str = replace (v-str,"nadpistwo","").
            next.
        end.
        if v-str matches "*rnnsender*" then do:
            if v-m2 <> "" then v-str = replace (v-str,"rnnsender",trim(v-m2)).
            else v-str = replace (v-str,"rnnsender","").
            next.
        end.
        if v-str matches "*sendermoneyone*" then do:
            if v-m1 <> "" then do:
                if length(trim(v-m1)) >= 70 then v-str = replace (v-str,"sendermoneyone",trim(substr(trim(v-m1),1,70))).
                else v-str = replace (v-str,"sendermoneyone",trim(v-m1)).
            end.
            else v-str = replace (v-str,"sendermoneyone","").
            next.
        end.
        if v-str matches "*sendermoneytwo*" then do:
            if v-m1 <> "" then do:
                if length(trim(v-m1)) > 70 then v-str = replace (v-str,"sendermoneytwo",trim(substr(trim(v-m1),71,length(trim(v-m1))))).
                else v-str = replace (v-str,"sendermoneytwo","").
            end.
            else v-str = replace (v-str,"sendermoneytwo","").
            next.
        end.
        if v-str matches "*recievebank*" then do:
            if v-bm1 <> "" then v-str = replace (v-str,"recievebank",trim(v-bm1)).
            else v-str = replace (v-str,"recievebank","").
            next.
        end.
        if v-str matches "*bikrecbnk*" then do:
            if v-kbm <> "" then v-str = replace (v-str,"bikrecbnk",trim(v-kbm)).
            else v-str = replace (v-str,"bikrecbnk","").
            next.
        end.
        if v-str matches "*iikaccsend*" then do:
            if v-km <> "" then v-str = replace (v-str,"iikaccsend",trim(v-km)).
            else v-str = replace (v-str,"iikaccsend","").
            next.
        end.
        if v-str matches "*kbe*" then do:
            if v-polrs <> "" then v-str = replace (v-str,"kbe",v-polrs).
            else v-str = replace (v-str,"kbe","").
            next.
        end.
        if v-str matches "*crccode*" then do:
            if crc.code <> "" then v-str = replace (v-str,"crccode",trim(crc.code)).
            else v-str = replace (v-str,"crccode","").
            next.
        end.
        if v-str matches "*rnnbeneficiary*" then do:
            if v-s2 <> "" then v-str = replace (v-str,"rnnbeneficiary",trim(v-s2)).
            else v-str = replace (v-str,"rnnbeneficiary","").
            next.
        end.
        if v-str matches "*beneficiaryone*" then do:
            if v-s1 <> "" then v-str = replace (v-str,"beneficiaryone",substr(trim(v-s1),1,70)).
            else v-str = replace (v-str,"beneficiaryone","").
            next.
        end.
        if v-str matches "*beneficiarytwo*" then do:
            if v-s1 <> "" then v-str = replace (v-str,"beneficiarytwo",substr(trim(v-s1),71,length(trim(v-s1)))).
            else v-str = replace (v-str,"beneficiarytwo","").
            next.
        end.
        if v-str matches "*summop*" then do:
            if v-sm <> "" then v-str = replace (v-str,"summop",trim(v-sm)).
            else v-str = replace (v-str,"summop","").
            next.
        end.
        if v-str matches "*bbenficry*" then do:
            if v-bs1 <> "" then v-str = replace (v-str,"bbenficry",trim(v-bs1)).
            else v-str = replace (v-str,"bbenficry","").
            next.
        end.
        if v-str matches "*iikaccbene*" then do:
            if v-ks <> "" then v-str = replace (v-str,"iikaccbene",trim(v-ks)).
            else v-str = replace (v-str,"iikaccbene","").
            next.
        end.
        if v-str matches "*kbudklas*" then do:
            if v-ks1 <> "" then v-str = replace (v-str,"kbudklas",trim(v-ks1)).
            else v-str = replace (v-str,"kbudklas","").
            next.
        end.
        if v-str matches "*bnkposrednikone*" then do:
            v-str = replace (v-str,"bnkposrednikone","").
            next.
        end.
        if v-str matches "*bnkposredniktwo*" then do:
            v-str = replace (v-str,"bnkposredniktwo","").
            next.
        end.
        if v-str matches "*bikposrbnk*" then do:
            v-str = replace (v-str,"bikposrbnk","").
            next.
        end.
        if v-str matches "*sumpropis*" then do:
            if v-sumt[1] <> "" then v-str = replace (v-str,"sumpropis",trim(v-sumt[1]) + trim(v-sumt[2])).
            else v-str = replace (v-str,"sumpropis","").
            next.
        end.
        if v-str matches "*naznplatone*" then do:
            if v-detch <> "" then v-str = replace (v-str,"naznplatone",trim(v-detch)).
            else v-str = replace (v-str,"naznplatone","").
            next.
        end.
        if v-str matches "*naznplattwo*" then do:
            v-str = replace (v-str,"naznplattwo","").
            next.
        end.
        if v-str matches "*naznplatfree*" then do:
            v-str = replace (v-str,"naznplatfree","").
            next.
        end.
        if v-str matches "*naznplatfour*" then do:
            v-str = replace (v-str,"naznplatfour","").
            next.
        end.
        if v-str matches "*knplat*" then do:
            if v-knp <> "" then v-str = replace (v-str,"knplat",trim(v-knp)).
            else v-str = replace (v-str,"knplat","").
            next.
        end.
        if v-str matches "*dtvalutirovaniya*" then do:
            if remtrz.valdt2 <> ? then v-str = replace(v-str,"dtvalutirovaniya",string(remtrz.valdt2,'99/99/9999')).
            else v-str = replace (v-str,"dtvalutirovaniya","").
            next.
        end.
        if v-str matches "*bikbnfecbnk*" then do:
            if v-kbs <> "" then v-str = replace(v-str,"bikbnfecbnk",v-kbs).
            else v-str = replace (v-str,"bikbnfecbnk","").
            next.
        end.
        if v-str matches "*namerukovodelone*" then do:
            if v-chief <> '' then v-str = replace (v-str,"namerukovodelone",trim(glbuhgalter)).
            else v-str = replace (v-str,"namerukovodelone","").
            next.
        end.
        if v-str matches "*namerukovodeltwo*" then do:
            if v-chief <> '' then v-str = replace (v-str,"namerukovodeltwo",trim(v-chief)).
            else v-str = replace (v-str,"namerukovodeltwo","").
            next.
        end.
        if v-str matches "*leader*" then do:
            v-str = replace (v-str,"leader","").
            next.
        end.
        if v-str matches "*bookkeeper*" then do:
            v-str = replace (v-str,"bookkeeper","").
            next.
        end.
        if v-str matches "*tempone*" then do:
            find first ofc where ofc.ofc = g-ofc no-lock no-error.
            if avail ofc then v-str = replace (v-str,"tempone",trim(ofc.name)).
            else v-str = replace (v-str,"tempone","").
            next.
        end.
        if v-str matches "*temptwo*" then do:
            v-str = replace (v-str,"temptwo","").
            next.
        end.
        if v-str matches "*kemprovedeno*" then do:
            if remtrz.source = 'IBH' then v-str = replace (v-str,"kemprovedeno","Проведено по системе Интернет-Банкинг").
            else v-str = replace (v-str,"kemprovedeno","Проведено банком - получателем").
            next.
        end.
        if v-str matches "*RNBNIN*" then do:
            if v-bin then do:
                if remtrz.valdt1 ge v-bin_rnn_dt then v-str = replace (v-str,"RNBNIN","ИИН(БИН)").
                else v-str = replace (v-str,"RNBNIN","РНН").
            end.
            else v-str = replace (v-str,"RNBNIN","РНН").
            next.
        end.
        if v-str matches "*nameglavbuh*" then do:
            if v-kbs = "FOBAKZKA" then v-str = replace (v-str,"nameglavbuh","").
            else v-str = replace (v-str,"nameglavbuh",if avail b-sub-cod then trim(b-sub-cod.rcode) else "").
            next.
        end.
        if v-str matches "*asdlkjhfiurhfekjhasf*" then do:
            if v-kbs = "FOBAKZKA" then v-str = replace (v-str,"asdlkjhfiurhfekjhasf","").
            else v-str = replace (v-str,"asdlkjhfiurhfekjhasf","Главный бухгалтер").
            next.
        end.
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.




