/* PKI_ps.p
 * MODULE
        Потребкредит
 * DESCRIPTION
        Обработка интернет-анкет
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
        20/05/2005 madiyar
 * CHANGES
        27/05/2005 madiyar - временно добавил свой ящик для тестирования
        23/06/2005 madiyar - номер анкеты еще сбрасывается по почте Головлевой Насте
        30/06/2005 madiyar - изменения в сообщении, отправляемом клиенту в случае одобрения
                             v-paramminsum = 40000, а не из справочника (в справочнике - для филиалов)
        10/08/2005 madiyar - всем, независимо от рез-та, отправляется стандартное сообщение
        16/08/2005 madiyar - добавил адрес в список рассылки
        02/09/2005 madiyar - шаренная переменная v-repeat для повторных кредитов
        13/01/2006 madiyar - справочник в sysc'е - список адресов для рассылки
        28/02/2006 madiyar - анкеты через казпочту
        02/03/2006 madiyar - рассылка почтовых анкет
        03/03/2006 madiyar - если еще нет ответа из ГЦВП - молча пропускаем
        03/05/2006 madiyar - подправил обработку казпочтовых анкет
        24/04/2007 madiyar - веб-анкеты
        25/04/2007 madiyar - по коммерсантам ГЦВП не отправляем
        28/04/2007 madiyar - второй пакет договоров (pkdoc2)
        07/05/2007 madiyar - выдача кредита в кассе
        12/09/2007 madiyar - run value("pkafterank-" + string(s-credtype)) вместо run pkafterank-6
        18/09/2007 madiyar - немножко изменил передачу сообщений об ошибках (fmsg)
        21/09/2007 madiyar - номера обрабатываемых анкет пишутся в pksysc "anklst"
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        25/11/09 marinav - для нестандартной подписи в ЦО масштаб не указываем
        20/12/2009 galina - добавила передачу параметра для процедуры plongrf
*/

{global.i}
{pk0.i}
{sysc.i}

define new shared var s-credtype as char init '6'.
define new shared var s-pkankln like pkanketa.ln.

{pk-sysc.i}

{comm-txb.i}
define new shared var s-ourbank as char.
s-ourbank = comm-txb().

/* для совместимости с pkafterank-6 */
define new shared var s-dogsign as char init "<IMG border=""0"" src=""c:\\tmp\\pkdogsgn.jpg"" width=""180"" height=""60"" v:shapes=""_x0000_s1026"">".
define new shared var s-lon as char init ''.
define new shared var s-tempfolder as char init ''.
/* для совместимости с pkafterank-6 - конец */

define new shared var v-maillist as char.
v-maillist = get-sysc-cha ("pkinet").
define new shared var v-email as char.

define new shared var v-fmsg as char no-undo.

def new shared temp-table t-anket like pkanketh.

define var v-cif like cif.cif.
define var v-name as char no-undo.
define var v-rko as char no-undo.
define var fname as char no-undo.
define var v-dira as char no-undo.
define var v-diri as char no-undo.
define var v-msg as char no-undo.
define buffer b-pkanketa for pkanketa.
def var i as integer no-undo.
def var v-str as char no-undo.
def var v-ph_file as char no-undo.
def var v-anklist as char no-undo.
def var v-anklist2 as char no-undo.
def var v-pos as integer no-undo.

if  s-ourbank = "TXB00" then s-dogsign = "<IMG border=""0"" src=""c:\\tmp\\pkdogsgn.jpg"" v:shapes=""_x0000_s1026"">". 

def var v-paramminsum as decimal init 40000. /* по умолчанию 40000 KZT */.

for each pkanketa where pkanketa.sts = "80" /* and pkanketa.credtype = s-credtype */ and pkanketa.bank = s-ourbank no-lock:
    
    if not (pkanketa.id_org = "inet" or pkanketa.id_org = "wclient") then next.
    s-credtype = pkanketa.credtype.
    s-pkankln = pkanketa.ln.
    
    v-fmsg = ''.
    
    v-email = ''.
    if pkanketa.id_org = "inet" then v-email = g-ofc + "@metrobank.kz".
    else if pkanketa.id_org = "wclient" then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "e-mail" no-lock no-error.
        if avail pkanketh and trim(pkanketh.value1) <> '' then v-email = trim(pkanketh.value1).
    end.
    
    run savelog( "ianketa.log", "Пост-ГЦВП " + pkanketa.id_org + " " + string(pkanketa.ln) + ", старт").
    
    /* пришел ли ответ из ГЦВП */
    if s-credtype <> '7' then do:
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "sik" no-lock no-error.
        if num-entries(pkanketh.rescha[3],";") = 1 then do:
            /* файл был, но ответ не импортировался */
            fname = entry(1,pkanketh.rescha[3],";").
            
            v-dira = get-sysc-cha ("pkgcva").
            v-diri = get-sysc-cha ("pkgcvi").
            
            FILE-INFO:FILE-NAME = v-diri + fname.
            
            if FILE-INFO:FILE-TYPE = ? then do:
                run savelog( "ianketa.log", "Пост-ГЦВП " + pkanketa.id_org + " " + string(pkanketa.ln) + ", файл ответа отсутствует").
                next.
            end.
            
        end.
    end.
    
    run savelog( "ianketa.log", "Пост-ГЦВП " + pkanketa.id_org + " " + string(pkanketa.ln) + ", старт обработки критериев").
    run ianketa2.
    run savelog( "ianketa.log", "Пост-ГЦВП " + pkanketa.id_org + " " + string(pkanketa.ln) + ", конец обработки критериев").
    
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
    v-cif = "".
    if pkanketh.value1 <> "" then do:
        /* поиск существующего кода клиента - ищем только по нашим кредитам! */
        find first b-pkanketa where b-pkanketa.bank = s-ourbank and b-pkanketa.rnn = pkanketh.value1 and b-pkanketa.cif <> "" no-lock no-error.
        if avail b-pkanketa then v-cif = b-pkanketa.cif.
    end.
    
    do transaction:
        find first b-pkanketa where b-pkanketa.bank = s-ourbank and b-pkanketa.credtype = pkanketa.credtype and b-pkanketa.ln = pkanketa.ln exclusive-lock.
        
        b-pkanketa.cif = v-cif.
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
        if avail pkanketh then b-pkanketa.rnn = pkanketh.value1.
        
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "sik" no-lock no-error.
        if avail pkanketh then b-pkanketa.sik = pkanketh.value1.
        
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
        if avail pkanketh then b-pkanketa.docnum = pkanketh.value1.
        
        /* собрать полное имя по анкете */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "lname" no-lock no-error.
        if avail pkanketh then v-name = caps(trim(pkanketh.value1)).
        
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "fname" no-lock no-error.
        if avail pkanketh then do:
            if v-name <> "" then v-name = v-name + " ".
            v-name = v-name + caps(trim(pkanketh.value1)).
        end.
        
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "mname" no-lock no-error.
        if avail pkanketh then do:
            if v-name <> "" then v-name = v-name + " ".
            v-name = v-name + caps(trim(pkanketh.value1)).
        end.
        
        /* заменить казахские буквы на русские */
        run pkdeffio (input-output v-name).
        b-pkanketa.name = v-name.
        
        /* переписать результаты проверки в АКИ - только интернет-анкеты */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "akires" no-lock no-error.
        if avail pkanketh then b-pkanketa.rescha[2] = pkanketh.value2.
        
        release b-pkanketa.
    end. /* transaction */
    
    run value("pkafterank-" + string(s-credtype)).
    
    run savelog( "ianketa.log", "Пост-ГЦВП " + pkanketa.id_org + " " + string(pkanketa.ln) + ", финиш, отправка сообщения").
    
    v-msg = s-ourbank + ", анкета " + string(s-pkankln) + " " + pkanketa.name + ", sts=" + pkanketa.sts.
    
    if v-fmsg <> '' then do:
        
        do transaction:
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
            if not avail pkanketh then do:
                create pkanketh.
                pkanketh.bank = pkanketa.bank.
                pkanketh.credtype = pkanketa.credtype.
                pkanketh.ln = pkanketa.ln.
                pkanketh.kritcod = "fmsg".
            end.
            pkanketh.value1 = v-fmsg.
            find current pkanketh no-lock.
        end.
        
        v-msg = v-msg + "\n".
        do i = 1 to num-entries(v-fmsg,"|"):
            v-msg = v-msg + "\n" + entry(i,v-fmsg,"|").
        end.
        
    end. /* if v-fmsg <> '' */
    
    if v-email <> '' then do:
        if pkanketa.id_org = "wclient" then run mail(v-email, "METROBANK <abpk@metrobank.kz>", "Интернет-анкета", "Свяжитесь, пожалуйста, с менеджером отдела кредитования ТОО ""МКО ""Народный Кредит"".\n\nВнимание! Данная заявка действительна в течение 5 рабочих дней.", "1", "", "").
        else if pkanketa.id_org = "inet" then run mail(v-email, "METROBANK <abpk@metrobank.kz>", "Интернет-анкета " + pkanketa.id_org, v-msg, "1", "", "").
    end.
    if v-maillist <> '' then run mail(v-maillist, "METROBANK <abpk@metrobank.kz>", "Интернет-анкета " + pkanketa.id_org, v-msg, "1", "", "").
  
end. /* for each pkanketa */

for each pkanketa where pkanketa.sts = "75" /* and pkanketa.credtype = s-credtype */ and pkanketa.bank = s-ourbank no-lock:
    
    if not (pkanketa.id_org = "inet" or pkanketa.id_org = "wclient") then next.
    
    s-credtype = pkanketa.credtype.
    s-pkankln = pkanketa.ln.
    
    v-email = ''.
    if pkanketa.id_org = "inet" then v-email = g-ofc + "@metrobank.kz".
    else if pkanketa.id_org = "wclient" then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "e-mail" no-lock no-error.
        if avail pkanketh and trim(pkanketh.value1) <> '' then v-email = trim(pkanketh.value1).
    end.
    
    v-fmsg = ''.
    
    run savelog( "ianketa.log", "Пре-ГЦВП " + pkanketa.id_org + " " + string(pkanketa.ln) + ", старт").
    run ianketa1.
    run savelog( "ianketa.log", "Пре-ГЦВП " + pkanketa.id_org + " " + string(pkanketa.ln) + ", финиш ").
    
    if v-fmsg <> '' then do transaction:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
        if not avail pkanketh then do:
            create pkanketh.
            pkanketh.bank = pkanketa.bank.
            pkanketh.credtype = pkanketa.credtype.
            pkanketh.ln = pkanketa.ln.
            pkanketh.kritcod = "fmsg".
        end.
        pkanketh.value1 = v-fmsg.
        find current pkanketh no-lock.
    end.
    
end. /* for each pkanketa */

def var v-phdird as char.
v-phdird = get-sysc-cha ("pkphd").
if substr(v-phdird,length(v-phdird),1) <> "/" then v-phdird = v-phdird + "/".

for each pkanketa where pkanketa.sts = "12" and pkanketa.bank = s-ourbank no-lock:
    
    if pkanketa.id_org <> "inet" then next.
    
    s-credtype = pkanketa.credtype.
    s-pkankln = pkanketa.ln.
    
    v-email = g-ofc + "@metrobank.kz".
    
    /*
    v-fmsg = ''.
    */
    
    /* проверка наличия фотографии, копирование фото с /var/www/html/docs/[credtype]/[ln]/photo.jpg в /data/alm/export/dpk/docs/photos/[ln]-photo.jpg */
    v-ph_file = "/var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/photo.jpg".
    input through value("if [ -f " + v-ph_file + " ]; then echo 1; else echo 0; fi").
    import unformatted v-str.
    v-str = trim(v-str).
    input close.
    
    if v-str = '1' then do:
        
        unix silent value ("if [ ! -d " + v-phdird + string(year(pkanketa.rdt)) + " ]; then mkdir " + v-phdird + string(year(pkanketa.rdt)) + "; chmod a+rx " + v-phdird + string(year(pkanketa.rdt)) + "; fi").
        unix silent value ("if [ ! -d " + v-phdird + string(year(pkanketa.rdt)) + "/" + string(month(pkanketa.rdt)) + " ]; then mkdir " + v-phdird + string(year(pkanketa.rdt)) + "/" + string(month(pkanketa.rdt)) + "; chmod a+rx " + v-phdird + string(year(pkanketa.rdt)) + "/" + string(month(pkanketa.rdt)) + "; fi").
        v-phdird = v-phdird + string(year(pkanketa.rdt)) + "/" + string(month(pkanketa.rdt)) + "/".
        unix silent value("cp " + v-ph_file + " " + v-phdird + string(s-pkankln) + "-photo.jpg").
        
        /* формирование договоров, статус меняем на 20 */    
        run pklondog.
        run pkkksogl.
        
    end.
    else do transaction:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
        if not avail pkanketh then do:
            create pkanketh.
            pkanketh.bank = pkanketa.bank.
            pkanketh.credtype = pkanketa.credtype.
            pkanketh.ln = pkanketa.ln.
            pkanketh.kritcod = "fmsg".
        end.
        pkanketh.value1 = 'К анкете не привязана фотография!'.
        find current pkanketh no-lock.
    end.
    
end. /* for each pkanketa */

for each pkanketa where pkanketa.sts = "21" and pkanketa.bank = s-ourbank no-lock:
    
    if pkanketa.id_org <> "inet" then next.
    
    s-credtype = pkanketa.credtype.
    s-pkankln = pkanketa.ln.
    
    
    /* Проверка на наличие номера анкеты в списке, и запись в случае отсутствия */
    v-anklist = get-pksysc-char("anklst").
    if lookup(string(pkanketa.ln),v-anklist) > 0 then next.
    else do transaction:
        find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anklst" exclusive-lock no-error.
        if pksysc.chval <> '' then pksysc.chval = pksysc.chval + ','.
        pksysc.chval = pksysc.chval + string(pkanketa.ln).
        find current pksysc no-lock.
    end.
    /***************************************************************************/
    
    
    v-email = g-ofc + "@metrobank.kz".
    
    /* Открытие счетов, перевод средств, касса, формирование расходника и графика платежей, статус меняем на 99 */
    do transaction:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
        if not avail pkanketh then do:
            create pkanketh.
            pkanketh.bank = pkanketa.bank.
            pkanketh.credtype = pkanketa.credtype.
            pkanketh.ln = pkanketa.ln.
            pkanketh.kritcod = "fmsg".
        end.
        pkanketh.value1 = ''.
        find current pkanketh no-lock.
    end.
    
    do transaction:
        g-ofc = pkanketh.rescha[1].
        run pkcifnew.
        run pklongrf(yes).
        run pkkas.
    end.
    
    /* второй пакет договоров */
    run pkzaybuh.
    run pkzalogm.
    run pkspdoc.
    run pkpril.
    g-ofc = 'superman'.
    
    
    /* Удаление номера анкеты из списка */
    do transaction:
        find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anklst" exclusive-lock no-error.
        v-anklist = pksysc.chval.
        v-pos = lookup(string(pkanketa.ln),v-anklist).
        if v-pos > 0 then do:
            v-anklist2 = ''.
            do i = 1 to num-entries(v-anklist):
                if i <> v-pos then do:
                    if v-anklist2 <> '' then v-anklist2 = v-anklist2 + ','.
                    v-anklist2 = v-anklist2 + entry(i,v-anklist).
                end.
            end.
        end.
        pksysc.chval = v-anklist2.
        find current pksysc no-lock.
    end.
    /*****************************************/
    
    
end. /* for each pkanketa */
