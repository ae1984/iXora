/* ipacpt.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        08.09.2004 tsoy Добавил группировку до даты.
        06.05.2011 id00004 добавил экспорт счетов кэш-пуллинга
        17.05.2011 id00004 добавил поле Должность сотрудника
        29.06.11   id00004 добавил отправку пользователя на контроль согласно ТЗ-1055
        09.12.2011 id00004 добавил выбор режима Просмотр, Полный доступ
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        10.05.2012 aigul - добавила возможность редактирования поля признак доступа
        15.05.2012 aigul - добавила обязательный выбор Признака доступа через F2
        19.07.2012 evseev - добавил логирование
        27.08.2012 evseev - иин/бин
        01.10.2013 yerganat - добавил признак резидентства и код страны гражданства для сотрудника
        28.10.2013 yerganat - редактирование v_auth_type, tz2169

*/

{global.i}

define shared variable ib-brnch as char.

define temp-table t-users
       field v_r_regnum as char
       field v_r_date as date
       field v_r_org as char
       field v_r_bin as char
       field v_r_fam as char
       field v_r_name as char
       field v_r_otch as char
       field v_r_dol as char
       field v_r_mail as char
       field v_s_fam  as char
       field v_s_name as char
       field v_s_otch  as char
       field v_s_resident  as char
       field v_s_dolgn  as char
       field v_s_datebirth as date
       field v_s_num as char
       field v_s_org as char
       field v_s_date as date
       field v_s_srok as date
       field v_s_iin as char
       field v_s_citizenship as char
       field v_s_sik as char
       field v_s_nomtel as char
       field v_s_nomscell as char
       field v_s_nomfax as char
       field v_s_email as char
       field v_s_addr as char
       field v_login as char
       field v_auth_type as char.

def var i as int.
def var s as char.
def var j as int.
def var v-name as char.
def var blval as char.
def var v-date as date format "99/99/9999".
def var v_fam as char.
def var v_name as char.
def var v_otch as char.
def var v_dolg as char.
def var v_login as char.
def var v_r_regnum as char.
def var v_r_date   as date.
def var v_r_org    as char.
def var v_r_bin    as char.
def var v_r_fam    as char.
def var v_r_name   as char.
def var v_r_otch   as char.
def var v_r_dol    as char.
def var v_s_fam as char.
def var v_s_name as char.
def var v_s_otch  as char.
def var v_s_resident as char.
def var v_s_dolgn  as char.
def var v_s_datebirth as date.
def var v_s_num as char.
def var v_s_org as char.
def var v_s_date as date.
def var v_s_srok as date.
def var v_s_iin as char.
def var v_s_citizenship as char.
def var v_s_nomtel as char.
def var v_s_nomscell as char.
def var v_s_email as char.
def var v_s_addr as char.
def var v_r_mail as char.
def var v_auth_type as char.
def var v-chk-help as logical initial no.
def var v-chetk  as char.
def var v_comm as decimal.
def var v-comm as logical initial no.
def var v-chk-comm as logical initial no.
def var v-gl as int.
def var v-glrem as char no-undo.
def var v-arp as char.
def var vdel as char no-undo initial "^".
def var v-param as char.
def var rcode as int.
def var rdes as char.
def var s-jh as int.
def var v-jh as int.
def var v-sqn as integer.

def var is_iin_check as logical  init yes.

def buffer b-usr for usr.
def QUERY q-help FOR aaa, lgr.
def BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.

def button bt-rmbl label  "Подтвердить пользование" .
def button bt-exflow label "Netbank".
def button bt-exit label "Выход".

def frame infr1
    v_r_fam  format "x(50)"          label  "Фамилия руководителя      " validate(v_r_fam <> "", "Неверное значение")          skip
    v_r_name  format "x(50)"         label  "Имя     руководителя      " validate(v_r_name <> "", "Неверное значение")         skip
    v_r_otch  format "x(50)"         label  "Отчество руководителя     " skip
    v_r_dol  format "x(50)"          label  "Должность руководителя    " validate(v_r_dol <> "", "Неверное значение")       skip
    v_r_mail  format "x(50)"         label  "E-mail организации        " validate(v_r_mail <> "" and v_r_mail matches "*@*", "Неверный E-mail(Обязательно наличие e-mail,  при его отсутствии регистрация невозможна)")       skip
    v_s_fam  format "x(50)"          label  "Фамилия сотрудника        " validate(v_s_fam <> "", "Неверное значение")           skip
    v_s_name  format "x(50)"         label  "Имя  сотрудника           " validate(v_s_name <> "", "Неверное значение")  skip
    v_s_otch  format "x(50)"         label  "Отчество сотрудника       " skip
    v_s_resident  format "x(50)"     label  "Резидентство сотрудника   " validate(v_s_resident = "резидент" or v_s_resident = "нерезидент", "неверное значение нажмите F2 для выбора ")  skip
    v_s_dolgn  format "x(50)"        label  "Должность сотрудника      " validate(v_s_dolgn <> "", "Неверное значение")  skip
    v_s_datebirth                    label  "Дата рождения             " format "99/99/9999" validate(v_s_datebirth <> ?, "Неверное значение") skip
    v_s_num  format "x(50)"          label  "№ Удостоверения           " validate(v_s_num <> "" and not v_s_num matches "*№*" and length(v_s_num) >= 9 , 'Недопустимы пустые строки а также символ №, Длина поля должна быть > 9 (По вопросам просьба обращаться в ОД тел. 192)')  skip
    v_s_org  format "x(50)"          label  "Орган выдавший            " validate(v_s_org <> "", "Неверное значение")  skip
    v_s_date                         label  "Дата выдачи               " format "99/99/9999" validate(v_s_date <> ?, "Неверное значение")  skip
    v_s_iin  format "x(50)"          label  "ИИН                       " validate(if is_iin_check = yes then v_s_iin <> "" else true, "Неверное значение") skip
    v_s_citizenship  format "x(50)"  label  "Код страны гражданства    " validate(v_s_citizenship <> "" and can-find(codfr where codfr.codfr = 'iso3166' and codfr.code = v_s_citizenship no-lock), "Неверное значение") skip
    v_s_nomtel  format "x(50)"       label  "Номер телефона            " validate(v_s_nomtel <> "", "Неверное значение")  skip
    v_s_nomscell  format "x(50)"     label  "Номер сотового            " skip
    v_s_email  format "x(50)"        label  "E-mail  сотрудника        " validate(v_s_email <> "" and v_s_email matches "*@*", "Неверный E-mail(Обязательно наличие e-mail,  при его отсутствии регистрация невозможна)")  skip
    v_s_addr  format "x(50)"         label  "Адрес сотрудника          " skip
    v_auth_type format "x(50)"       label  "Признак доступа           " validate(v_auth_type = "режим <ПРОСМОТР>" or v_auth_type = "режим <ПОЛНЫЙ ДОСТУП>", "неверное значение нажмите F2 для выбора ")  skip
    v_login  format "x(50)"          label  "Логин сотрудника          " validate(v_login <> "", "Неверное значение")  skip
    with side-labels centered row 6.
def frame f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
def frame ibblock
    usr.id format ">>>>>>9" label "IО клиент " view-as text     skip
    usr.cif format "x(6)" label "CIF" view-as text skip
    v-name format "x(60)" label  "Наименование " view-as text skip
    blval  format "x(13)"   label "Статус    "  view-as text
    v-date  format "99/99/9999"   label "Дата блок."  view-as text        skip
    usr.ip_trust[20] format "x(21)" label "Признак доступа организации" view-as text skip
    skip (1)
    bt-exit  bt-rmbl   bt-exflow  skip
    with side-labels row 7 centered.

on help of v_s_resident in frame infr1 do:
    run sel ("Резидентство", "резидент|нерезидент").
    if int(return-value) = 1 then do:
        v_s_resident = 'резидент'.
    end. else do:
        v_s_resident = 'нерезидент'.
    end.
    displ v_s_resident with frame infr1.
end.

on help of v_s_citizenship in frame infr1 do:
    {itemlist.i
    &file    = "codfr"
    &frame   = "row 6 centered scroll 1 30 down overlay "
    &where   = "codfr.codfr = 'iso3166'"
    &flddisp = " codfr.code label 'Код' format 'x(2)'
                 codfr.name[1] label 'Страна' format 'x(50)' "
    &chkey   = "code"
    &index   = "cdco_idx"}
    if avail codfr then do:
        v_s_citizenship = codfr.code.
    end.
    displ v_s_citizenship with frame infr1.
end.

on help of v_auth_type in frame infr1 do:
   run savelog( "ipacpt", "168. " + string(usr.id) + " " + string(usr.cif)).
   v-chk-help = yes.
   run sel ("Выберите тип доступа", "режим <ПРОСМОТР>|режим <ПОЛНЫЙ ДОСТУП>").
   if int(return-value) <> 1 and usr.ip_trust[20] = "режим <ПРОСМОТР>" then  do:
       run savelog( "ipacpt", "172. " + string(usr.id) + " " + string(usr.cif)).
       message "Ошибка: в договоре проставлен признак - режим <ПРОСМОТР>"  view-as alert-box question buttons ok title "".
   end. else do:
        run savelog( "ipacpt", "175. " + string(usr.id) + " " + string(usr.cif)).
        v_auth_type = "".
        v-chk-comm = yes.
        usr.ip_trust[20] = "".
        if int(return-value) = 1 then v_auth_type = "режим <ПРОСМОТР>". else v_auth_type = "режим <ПОЛНЫЙ ДОСТУП>".
        if v_auth_type = "режим <ПРОСМОТР>" or usr.ip_trust[20] = "режим <ПРОСМОТР>" then v-chk-comm = yes.
        if v_auth_type = "режим <ПОЛНЫЙ ДОСТУП>" or usr.ip_trust[20] = "режим <ПОЛНЫЙ ДОСТУП>" then do:
            run savelog( "ipacpt", "182. " + string(usr.id) + " " + string(usr.cif)).
            v-chk-comm = no.
            message "Списать комиссию за выпуск ЭЦП?" view-as alert-box question buttons yes-no title "" update v-dostup as logical.
            run savelog( "ipacpt", "185. " + string(usr.id) + " " + string(usr.cif) + " " + string(v-dostup)).
            if v-dostup then do:
                find first aaa where aaa.cif = usr.cif and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc = 1 and length(aaa.aaa) >= 20 no-lock no-error.
                if available aaa then do:
                    OPEN QUERY  q-help FOR EACH aaa where aaa.cif = usr.cif and aaa.sta <> "C" and aaa.sta <> "E" and aaa.crc = 1 and length(aaa.aaa) >= 20 no-lock, each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
                    ENABLE ALL WITH FRAME f-help.
                    wait-for return of frame f-help
                    FOCUS b-help IN FRAME f-help.
                    v-chetk = aaa.aaa.
                    hide frame f-help.
                end.
            end.
            find first tarif2 where tarif2.kont = 460828 no-lock no-error.
            if avail tarif2 then do: v_comm = tarif2.ost. end.
            find first aaa where aaa.aaa = v-chetk no-lock no-error.
            if avail aaa then do:
                run savelog( "ipacpt", "201. " + string(usr.id) + " " + string(usr.cif) + " " + string(aaa.aaa)).
                v-gl = aaa.gl.
                if v_comm > aaa.cbal - aaa.hbal then do:
                    run savelog( "ipacpt", "204. " + string(usr.id) + " " + string(usr.cif) + " " + string(aaa.aaa)).
                    MESSAGE "Ошибка, на выбранном счете недостаточно средств ~nдля списания комиссии" VIEW-AS ALERT-BOX.
                    v-chk-comm = no.
                end.
                if not (aaa.gl = 220310 or aaa.gl = 220420 or aaa.gl = 220520) then do:
                    run savelog( "ipacpt", "209. " + string(usr.id) + " " + string(usr.cif) + " " + string(aaa.aaa)).
                    MESSAGE "Комиссию можно снять только со счетов открытых на счетах ГК 220310, 220420, 220520 в тенге" VIEW-AS ALERT-BOX.
                    v-chk-comm = no.
                end.
                find first arp where arp.gl = 287082 no-lock no-error.
                if avail arp then v-arp = arp.arp.
                v-param = "".
                s-jh = 0.
                v-glrem = "Комиссия за выпуск электронной цифровой подписи (ЭЦП)".
                v-param = string(v_comm) + vdel +
                          "1" + vdel +
                          v-chetk + vdel +
                          v-arp + vdel +
                          v-glrem + vdel +
                          "840".
                run trxgen ("jou0068", vdel, v-param, "cif", v-chetk, output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    run savelog( "ipacpt", "226. " + string(usr.id) + " " + string(usr.cif) + " " + string(aaa.aaa)).
                    v-chk-comm = no.
                    v-comm = no.
                    message rdes.
                    pause 1000.
                    next.
                end. else do:
                   run savelog( "ipacpt", "233. " + string(usr.id) + " " + string(usr.cif) + " " + string(aaa.aaa) + " " + string(s-jh)).
                   run trxsts(s-jh, 6, output rcode, output rdes).
                   if rcode ne 0 then do:
                      run savelog( "ipacpt", "236. " + string(usr.id) + " " + string(usr.cif) + " " + string(aaa.aaa) + " " + string(s-jh)).
                      run savelog( "ipacpt", "237. " + aaa.aaa + " " + rdes).
                      message rdes view-as alert-box title "". undo,retry.
                   end. else do:
                      run savelog( "ipacpt", "240. " + string(usr.id) + " " + string(usr.cif) + " " + string(aaa.aaa) + " " + string(s-jh)).
                      v-chk-comm = yes.
                      v-comm = yes.
                      v-jh = s-jh.
                      for each jh where jh.jh = v-jh exclusive-lock:
                          jh.party = "057".
                      end.
                   end.
                end.
            end.
        end.
        if v-dostup = no then do:
           run savelog( "ipacpt", "252. " + string(usr.id) + " " + string(usr.cif)).
           v-chk-comm = yes.
           v-comm = no.
        end.
   end.
   displ v_auth_type with frame infr1.
end.

on "choose" of bt-exflow do:
   run savelog( "ipacpt", "261. " + string(usr.id) + " " + string(usr.cif)).
   v-sqn =  next-value(msgid).
   find last cif where cif.cif = usr.cif no-lock no-error.
   if avail cif then do:
      run savelog( "ipacpt", "265. " + string(usr.id) + " " + string(usr.cif)).
      if cif.ref[8] matches "*№*"   then do:
         run savelog( "ipacpt", "267. " + string(usr.id) + " " + string(usr.cif)).
         message "В карточке клиента, в свидетельстве о регистрации присутствует знак №. Продолжение невозможно ".  pause . return.
      end.
      if cif.ref[8] matches "*#*"   then do:
         run savelog( "ipacpt", "271. " + string(usr.id) + " " + string(usr.cif)).
         message "В карточке клиента, в свидетельстве о регистрации присутствует знак #. Продолжение невозможно ".  pause . return.
      end.
      if length(cif.name)  > 60 then do:
         run savelog( "ipacpt", "275. " + string(usr.id) + " " + string(usr.cif)).
         message "Название компании в пункте 1-1-2 превышает 60 символов. Продолжение невозможно ".  pause . return.
      end.
      do j = 1 to 20 :
         run savelog( "ipacpt", "279. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
         if j <> 1  then do:
            run savelog( "ipacpt", "281. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
            if v-chk-help = no then do:
               run savelog( "ipacpt", "283. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
               message "выбор Признака Доступа производится обязательно через клавишу F2!" view-as alert-box.
               return.
            end.
            if v-chk-comm then do:
               message "Добавить еще одного пользователя в для данной организации?" skip
                        view-as alert-box question buttons yes-no title "Добавление пользователя" update v-ans as logical.
               run savelog( "ipacpt", "279. " + string(usr.id) + " " + string(usr.cif) + " " + string(j) + " " + string(v-ans)).
            end.
         end. else do:
            run savelog( "ipacpt", "293. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
            v-ans = true.
         end.
         run savelog( "ipacpt", "296. " + string(usr.id) + " " + string(usr.cif) + " " + string(j) + " " + string(v-ans)).
         if v-ans then do:
            run savelog( "ipacpt", "298. " + string(usr.id) + " " + string(usr.cif) + " " + string(j) + " " + string(v-ans)).
            v_fam = "". v_name = "". v_otch = "". v_dolg = "". v_login = string(usr.login).
            find last webra where webra.cif = cif.cif and webra.login = v_login no-lock no-error.
            if avail webra then do:
               run savelog( "ipacpt", "302. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
               v_r_fam = webra.director_name.
               v_r_name = webra.info[1].
               v_r_otch = webra.info[2].
               v_s_fam = webra.info[3].
               v_s_name = webra.info[4].
               v_s_otch = webra.info[5].
               v_s_dolgn = webra.info[6].
               v_s_resident = webra.cln_resident.
               v_r_dol = webra.director_position.
               v_r_mail = webra.org_mail.
               v_s_datebirth  = webra.cln_birthdate.
               v_s_num  = webra.cln_passportnum.
               v_s_org =  webra.cln_issuer.
               v_s_date  = date(webra.cln_issuerdate).
               v_s_citizenship = webra.cln_citizenship.
               v_s_iin   = webra.cln_iin.
               v_s_nomtel = webra.cln_phone.
               v_s_nomscell  = webra.cln_mobile.
               v_s_email = webra.cln_email.
               v_s_addr = webra.cln_addres.
               v_auth_type = webra.info[7].
            end. else do:
               run savelog( "ipacpt", "324. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
               find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchf' and sub-cod.ccod = 'chief' no-lock no-error.
               if avail sub-cod then do:
                  v_r_fam = sub-cod.rcode.
                  v_s_fam = sub-cod.rcode.
               end.
               find last cif-mail where cif-mail.cif = cif.cif no-lock no-error.
               if avail cif-mail then do:
                  v_r_mail = cif-mail.mail.
                  v_s_email = cif-mail.mail.
               end.
               find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchfdnum' and sub-cod.ccod = 'chfdocnum' no-lock no-error.
               if avail sub-cod then do:
                  v_s_num = sub-cod.rcode.
               end.
               find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchfddt' and sub-cod.ccod = 'chfdocdt' no-lock no-error.
               if avail sub-cod then do:
                  v_s_date = date(sub-cod.rcode).
               end.
               v_s_nomtel  =  cif.tel.
               v_s_nomscell =  cif.tlx.
            end.

            if usr.ip_trust[20] = "режим <ПРОСМОТР>" then do:
               v_auth_type = 'режим <ПРОСМОТР>'.
            end.

            if j <> 1 then  do:
               v_login  = ''.
            end.

            display v_r_fam  v_r_name v_r_otch v_r_dol v_r_mail v_s_fam v_s_name v_s_resident v_s_otch v_s_dolgn
                    v_s_datebirth  v_s_num  v_s_org v_s_date v_s_citizenship v_s_iin v_s_nomtel v_s_nomscell
                    v_s_email v_s_addr v_auth_type v_login  with frame infr1.

            run savelog( "ipacpt", "360. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
            update v_r_fam  v_r_name v_r_otch v_r_dol v_r_mail v_s_fam v_s_name v_s_otch    with frame infr1.

            update v_s_resident    with frame infr1.
            if v_s_resident = "нерезидент" then do:
                is_iin_check = no.
                display v_s_iin  with frame infr1.
            end. else do:
                is_iin_check = yes.
            end.

            update v_s_dolgn v_s_datebirth  v_s_num  v_s_org v_s_date  v_s_iin with frame infr1.

            if v_s_resident = "нерезидент" then do:
                update v_s_citizenship with frame infr1.
            end. else do:
                v_s_citizenship = "".
                display v_s_citizenship  with frame infr1.

            end.

            update v_s_nomtel v_s_nomscell  v_s_email v_s_addr with frame infr1.

            if usr.ip_trust[20] <> "режим <ПРОСМОТР>" or j = 1 then do:
               update v_auth_type with frame infr1.
            end.

            if j <> 1 then  do:
               update v_login with frame infr1.
            end.

            find last b-usr where b-usr.login = v_login and b-usr.cif <> usr.cif no-lock no-error.
            find last webra where webra.login = v_login and webra.cif <> usr.cif no-lock no-error.
            if avail webra or avail b-usr then do:
               run savelog( "ipacpt", "379. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
               message "ОШИБКА: Логин уже закреплен за другим клиентом. ПРОДОЛЖЕНИЕ НЕВОЗМОЖНО" view-as alert-box. pause.
               return.
            end.


            v_r_date = cif.expdt.
            v_r_org = cif.sufix.
            v_r_bin = cif.bin.

            create t-users.
            t-users.v_r_regnum      = v_r_regnum .
            t-users.v_r_date        =  v_r_date.
            t-users.v_r_org         =  v_r_org.
            t-users.v_r_bin         =  v_r_bin.
            t-users.v_r_fam         =  v_r_fam.
            t-users.v_r_name        =  v_r_name.
            t-users.v_r_otch        =  v_r_otch.
            t-users.v_r_dol         =  v_r_dol.
            t-users.v_r_mail        =  v_r_mail.
            t-users.v_s_fam         =  v_s_fam.
            t-users.v_s_name        =  v_s_name.
            t-users.v_s_otch        =  v_s_otch.
            t-users.v_s_resident    =  v_s_resident.
            t-users.v_s_dolgn       =  v_s_dolgn.
            t-users.v_s_datebirth   =  v_s_datebirth.
            t-users.v_s_num         =  v_s_num.
            t-users.v_s_org         =  v_s_org.
            t-users.v_s_date        =  v_s_date.
            t-users.v_s_iin         =  v_s_iin.
            t-users.v_s_citizenship =  v_s_citizenship.
            t-users.v_s_nomtel      =  v_s_nomtel.
            t-users.v_s_nomscell    =  v_s_nomscell.
            t-users.v_s_email       =  v_s_email.
            t-users.v_s_addr        =  v_s_addr.
            t-users.v_auth_type     =  v_auth_type.
            t-users.v_login         =  v_login.

            find last webra where webra.cif = cif.cif and webra.login = v_login exclusive-lock no-error.
            if avail webra then do :
                   run savelog( "ipacpt", "417. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
                   webra.cif = cif.cif.
                   webra.login = v_login.
                   webra.org_mail = v_r_mail.
                   webra.certificate = v_r_regnum.
                   webra.cer_issuer = v_r_org.
                   webra.cert_issuer_date =  string(v_r_date).
                   webra.director_name = v_r_fam /*+ " " +  v_r_name + " " +  v_r_otch */.
                   webra.info[1] = v_r_name.
                   webra.info[2] = v_r_otch .
                   webra.director_position = v_r_dol.
                   webra.bin = v_r_bin.
                   webra.cln_position = v_r_dol.
                   webra.cln_birthdate = v_s_datebirth.
                   webra.cln_passportnum =  v_s_num.
                   webra.cln_issuer = v_s_org.
                   webra.cln_issuerdate = string(v_s_date).
                   webra.cln_resident = v_s_resident.
                   webra.cln_citizenship = v_s_citizenship.
                   webra.cln_iin = v_s_iin.
                   webra.cln_phone = v_s_nomtel.
                   webra.cln_mobile = v_s_nomscell.
                   webra.cln_email = v_s_email.
                   webra.cln_addres = v_s_addr.
                   webra.info[7] = v_auth_type.
                   webra.txb = ib-brnch.
                   webra.who = g-ofc.
                   webra.contrl = 1.
                   webra.info[3] =  v_s_fam.
                   webra.info[4] =  v_s_name.
                   webra.info[5] =  v_s_otch.
                   webra.info[6] =  v_s_dolgn.
                   webra.comm = v-comm.
                   webra.jh = v-jh.
            end. else do:
                 run savelog( "ipacpt", "451. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
                 create webra.
                   webra.cif = cif.cif.
                   webra.login = v_login.
                   webra.org_mail = v_r_mail.
                   webra.certificate = v_r_regnum.
                   webra.cer_issuer = v_r_org.
                   webra.cert_issuer_date =  string(v_r_date).
                   webra.director_name = v_r_fam  /*+ " " +  v_r_name + " " +  v_r_otch */ .
                   webra.info[1] = v_r_name.
                   webra.info[2] = v_r_otch .
                   webra.director_position = v_r_dol.
                   webra.bin = v_r_bin.
                   webra.cln_position = v_r_dol.
                   webra.cln_birthdate = v_s_datebirth.
                   webra.cln_passportnum =  v_s_num.
                   webra.cln_issuer = v_s_org.
                   webra.cln_issuerdate = string(v_s_date).
                   webra.cln_resident = v_s_resident.
                   webra.cln_citizenship = v_s_citizenship.
                   webra.cln_iin = v_s_iin.
                   webra.cln_phone = v_s_nomtel.
                   webra.cln_mobile = v_s_nomscell.
                   webra.cln_email = v_s_email.
                   webra.cln_addres = v_s_addr.
                   webra.info[7] = v_auth_type.
                   webra.txb = ib-brnch.
                   webra.who = g-ofc.
                   webra.jdt = g-today.
                   webra.contrl = 1.
                   webra.info[3] =  v_s_fam.
                   webra.info[4] =  v_s_name.
                   webra.info[5] =  v_s_otch.
                   webra.info[6] =  v_s_dolgn.
                   webra.comm = v-comm.
                   webra.jh = v-jh.
            end.
         end. else do:
           run savelog( "ipacpt", "488. " + string(usr.id) + " " + string(usr.cif) + " " + string(j)).
           leave.
         end.
      end.
      run savelog( "ipacpt", "492. " + string(usr.id) + " " + string(usr.cif)).
      message "Учетная запись отправлена на контроль" view-as alert-box .
   end. else do:
      run savelog( "ipacpt", "495. " + string(usr.id) + " " + string(usr.cif)).
      message "Не найден cif-код клиента" . pause.
   end.
end.

on "choose" of bt-rmbl do:
   run savelog( "ipacpt", "501. " + string(usr.id) + " " + string(usr.cif)).
   find last aaa where aaa.cif = usr.cif no-lock no-error.
   if not avail aaa  then do:
      run savelog( "ipacpt", "504. " + string(usr.id) + " " + string(usr.cif)).
      message "У клиента нет счетов для работы в интернет банкинге" . pause.
      return.
   end.
   create ib.hist.
   assign
       usr.perm[3] = 0
       ib.hist.type1 = 2
       ib.hist.type2 = 12
       ib.hist.procname = "IB_Platon_Menu"
       ib.hist.ip_addr = "platon"
       ib.hist.ip_name = g-ofc
       ib.hist.idusraff = usr.id
       blval = "не блокирован" .
   v-date = ? .
   release ib.hist.
   find last cif where cif.cif = usr.cif no-lock.
   v-name = cif.prefix + " " + cif.name .
   display usr.id blval usr.cif v-name v-date usr.ip_trust[20] with frame ibblock.
   pause 0.
end.

/* ================================================================= */
/*    M   A   I   N       C   O   D   E       B   L   O   C   K      */
/* ================================================================= */

do transaction:
    repeat :
        i = 0.
        update i label "Код клиента Интернет Офиса:" format ">>>>>>9" with side-labels row 1 no-error.
        find usr where usr.id = i no-lock no-error.
        if not available usr then do:
                message "Нет клиента с таким номером.".
        end. else if usr.bnkplc <> ib-brnch then do:
                message "Пользователь не в Вашем филиале.".
        end. else if usr.perm[6] = 1 then do:
                message "Договор закрыт.".
        end. else leave.
        pause 10.
        return.
    end.
    if error-status:error then return.
    if usr.perm[3] = 0 then blval = "не блокирован". else blval = "блокирован" .
    if usr.perm[3] = 1 then v-date = usr.block_date.
    find last cif where cif.cif = usr.cif no-lock.
    v-name = cif.prefix + " " + cif.name .
    display usr.id usr.cif v-name blval v-date usr.ip_trust[20] with frame ibblock.
    find current usr exclusive-lock.
    enable all with frame ibblock.
    wait-for "choose" of bt-exit.
end. /* transaction */