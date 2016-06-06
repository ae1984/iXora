/* val_functions.i
 * MODULE
        Общий
 * DESCRIPTION
        Заполнение хранилища данных для управленческих отчетов - функции
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
        04/05/2008 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        06/08/2008 madiyar - комиссии собираем по ГК
        28/11/2008 galina - добавила разбивку для программ физ.лиц
        10/12/2008 galina - для выданных кредитов берем сумму кредита
        15/12/2008 galina - исправила подсчет колличества кредитов для провозий
                            сумма провизий подсчитывается по курсу в тенге
                            добавила для кредитов ФЛ подсчет провизий 2,3,4 категории
*/

/* вспомогательные функции */

function glsum returns decimal (input v-gl as integer, input v-dat as date, input v-crc as integer, input v-fact as integer, input v-ob as char).
    def var v-sumgl as decimal init 0.
    find last txb.glday where txb.glday.gl = v-gl and txb.glday.crc = v-crc and txb.glday.gdt < v-dat no-lock no-error.
    if avail txb.glday then do:
       if v-ob = 'd' then v-sumgl = txb.glday.dam.
       else if v-ob = 'c' then v-sumgl = txb.glday.cam.
       else v-sumgl = txb.glday.dam - txb.glday.cam.
    end.
    return (v-sumgl * v-fact).
end function.

/* ------ кредитный портфель ---------- */

/* портфель - суммы */
procedure credport:
    def output parameter v-deval as deci no-undo.
    /*Ищем номер контаркта для экспресс кредитов*/
    if v-express then find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error. 

    case valspr.code:
        /* весь */          when 1 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* кредиты в KZT */ when 2 then if txb.lon.crc = 1 then v-deval = v-bal1 + v-bal7.
        /* кредиты в USD */ when 3 then if txb.lon.crc = 2 then v-deval = v-bal1 + v-bal7.       
        /* кредиты в EUR */ when 4 then if txb.lon.crc = 3 then v-deval = v-bal1 + v-bal7.
        /* ЮЛ */            when 5 then if v-ur then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* ФЛ */            when 6 then if not v-ur then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* ФЛ автокредит*/  when 148 then if txb.lon.grp = 25 or txb.lon.grp = 65 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* ФЛ ипотека*/     when 149 then if txb.lon.grp = 27 or txb.lon.grp = 67 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* ФЛ потреб цели*/ when 150 then if txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* краткосрочные */ when 7 then if v-kr then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* долгосрочные */  when 8 then if not v-kr then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        /* экспресс */      when 9 then if v-express then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        
/* экспресс стандартный*/   when 154 then if v-express and txb.loncon.lcnt matches "*ДК*" then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс льготный*/      when 155 then if v-express and txb.loncon.lcnt matches "*ЛК*" then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс коммерсант*/    when 156 then if v-express and txb.loncon.lcnt matches "*ПК*"then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
    end case.
end procedure.

/* портфель - кол-во */
procedure credport_cnt:
    def output parameter v-deval as deci no-undo.
    def var v-sum as deci no-undo.
    
    /*Ищем номер контаркта для экспресс кредитов*/
    if v-express then find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error. 
    
    v-sum = v-bal1 + v-bal7 + v-bal2 + v-bal9 + v-bal16 + v-bal4 + v-bal5 + v-bal13 + v-bal14 + v-bal30.
    case valspr.code:
        /* кредитов */           when 10 then if v-sum > 0 then v-deval = 1.
        /* заемщиков */          when 11 then if v-sum > 0 and txb.lon.cif <> v-cif then do: v-deval = 1. v-cif = txb.lon.cif. end.
        /* экспресс */           when 12 then if v-express and v-sum > 0 then v-deval = 1.
      /* экспресс стандартный*/  when 157 then if v-express and v-sum > 0 and txb.loncon.lcnt matches "*ДК*" then v-deval = 1.
      /* экспресс льготный*/     when 158 then if v-express and v-sum > 0 and txb.loncon.lcnt matches "*ЛК*" then v-deval = 1.
      /* экспресс коммерсант*/   when 159 then if v-express and v-sum > 0 and txb.loncon.lcnt matches "*ПК*" then v-deval = 1.
        /* заемщиков экспресс */ when 13 then if v-express and v-sum > 0 and txb.lon.cif <> v-cif_expr then do: v-deval = 1. v-cif_expr = txb.lon.cif. end.
        /* кредиты в KZT */      when 14 then if txb.lon.crc = 1 and v-sum > 0 then v-deval = 1.
        /* кредиты в USD */      when 15 then if txb.lon.crc = 2 and v-sum > 0 then v-deval = 1.
        /* кредиты в EUR */      when 16 then if txb.lon.crc = 3 and v-sum > 0 then v-deval = 1.
        /* ЮЛ */                 when 17 then if v-ur and v-sum > 0 then v-deval = 1.
        /* ФЛ */                 when 18 then if (not v-ur) and v-sum > 0 then v-deval = 1.
        /* ФЛ автокредиты*/      when 151 then if v-sum > 0 and (txb.lon.grp = 25 or txb.lon.grp = 65)then v-deval = 1.
        /* ФЛ ипотека*/          when 152 then if v-sum > 0 and (txb.lon.grp = 27 or txb.lon.grp = 67) then v-deval = 1.
        /* ФЛ потреб кредиты*/   when 153 then if v-sum > 0 and (txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66) then v-deval = 1.
        /* краткосрочные */      when 19 then if v-kr and v-sum > 0 then v-deval = 1.
        /* долгосрочные */       when 20 then if (not v-kr) and v-sum > 0 then v-deval = 1.
    end.
end procedure.

/* выданные кредиты */
procedure credvyd:
    def output parameter v-deval as deci no-undo.
    if txb.lon.rdt < v-dt and txb.lon.rdt >= v-begday then do:
          /*Ищем номер контаркта для экспресс кредитов*/
       if v-express then find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error. 

        case valspr.code:
            /* сумма выд. кредитов */ when 21 then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
            /* сумма ФЛ автокредит*/  when 160 then if txb.lon.grp = 25 or txb.lon.grp = 65 then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
            /* сумма ФЛ ипотека*/     when 161 then if txb.lon.grp = 27 or txb.lon.grp = 67 then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
            /* сумма ФЛ потреб цели*/ when 162 then if txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66 then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
            /* сумма выд. экспресс */ when 22 then if v-express then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
/*сумма выд. экспресс стандартный*/   when 163 then if v-express and txb.loncon.lcnt matches "*ДК*" then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
/*сумма выд. экспресс льготный*/      when 164 then if v-express and txb.loncon.lcnt matches "*ЛК*" then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
/*сумма выд. экспресс коммерсант*/    when 165 then if v-express and txb.loncon.lcnt matches "*ПК*"then v-deval = txb.lon.opnamt * rate[txb.lon.crc].
            
            /* кол-во кредитов */     when 23 then v-deval = 1.
  /* кол-во кредитов ФЛ автокредит*/  when 166 then if txb.lon.grp = 25 or txb.lon.grp = 65 then v-deval = 1.
  /* кол-во кредитов ФЛ ипотека*/     when 167 then if txb.lon.grp = 27 or txb.lon.grp = 67 then v-deval = 1.
  /* кол-во кредитов ФЛ потреб цели*/ when 168 then if txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66 then v-deval = 1.
            /* кол-во экспресс */     when 24 then if v-express then v-deval = 1.
/* кол-во выд. экспресс стандартный*/ when 169 then if v-express and txb.loncon.lcnt matches "*ДК*" then v-deval = 1.
/* кол-во выд. экспресс льготный*/    when 170 then if v-express and txb.loncon.lcnt matches "*ЛК*" then v-deval = 1.
/* кол-во выд. экспресс коммерсант*/  when 171 then if v-express and txb.loncon.lcnt matches "*ПК*"then v-deval = 1.
            
        end.
    end.
end procedure.

/* ------ погашенные кредиты ---------- */

procedure credpog:
    def output parameter v-deval as deci no-undo.
    def var v-sum as deci no-undo.
    def var v-sumz as deci no-undo.
    
    v-sum = v-bal1 + v-bal7 + v-bal2 + v-bal9 + v-bal16 + v-bal4 + v-bal5.
    v-sumz = v-bal13 + v-bal14 + v-bal30.
    case valspr.code:
        /* сумма пог. кредитов */       when 25 then v-deval = (txb.lon.opnamt - (v-bal1 + v-bal7)) * rate[txb.lon.crc]. /* !!!! переделать !!! */
        /* в т.ч. спис */               when 26 then do:
                                                       v-deval = 0.
                                                       for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.jdt < v-dt and txb.lonres.lev = 13 and txb.lonres.dc = 'C' no-lock:
                                                           v-deval = v-deval + txb.lonres.amt * rate[txb.lon.crc].
                                                       end.
                                                     end.
        /* сумма пог. экспресс */       when 27 then if v-express then v-deval = (txb.lon.opnamt - (v-bal1 + v-bal7)) * rate[txb.lon.crc].
        /* в т.ч. спис экспресс */      when 28 then if v-express then do:
                                                       v-deval = 0.
                                                       for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.jdt < v-dt and txb.lonres.lev = 13 and txb.lonres.dc = 'C' no-lock:
                                                           v-deval = v-deval + txb.lonres.amt * rate[txb.lon.crc].
                                                       end.
                                                     end.
        /* кол-во пог. кредитов */      when 29 then if v-sum <= 0 then v-deval = 1.
        /* в т.ч. кол. спис */          when 30 then if v-sum <= 0 and v-sumz > 0 then v-deval = 1.
        /* кол. спис. а потом погашенных кредитов */ when 145 then do:
                                                        if v-sum + v-sumz <= 0 then do:
                                                            find first txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.jdt < v-dt and txb.lonres.lev = 13 and txb.lonres.dc = 'C' no-lock no-error.
                                                            if avail txb.lonres then v-deval = 1.
                                                        end.
                                                     end.
        /* кол-во пог. экспресс */      when 31 then if v-express and v-sum <= 0 then v-deval = 1.
        /* в т.ч. кол. спис экспресс */ when 32 then if v-express and v-sum <= 0 and v-sumz > 0 then v-deval = 1.
        /* кол. спис. а потом погашенных кредитов ЭК */ when 146 then do:
                                                           if v-express and v-sum + v-sumz <= 0 then do:
                                                               find first txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.jdt < v-dt and txb.lonres.lev = 13 and txb.lonres.dc = 'C' no-lock no-error.
                                                               if avail txb.lonres then v-deval = 1.
                                                           end.
                                                        end.
    end case.
end procedure.

/* ------ провизии ---------- */

procedure credprov:
    def output parameter v-deval as deci no-undo.

    /*Ищем номер контаркта для экспресс кредитов*/
    if v-express then find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error. 
    
    case valspr.code:
        /* все провизии */              when 33 then v-deval = v-bal6 * rate[txb.lon.crc].
        /* все провизии по юр.лицам */  when 331 then if v-ur then v-deval = v-bal6 * rate[txb.lon.crc].
        /* стандартные */               when 34 then if v-lonstat = 1 then v-deval = v-bal6 * rate[txb.lon.crc].
        /* стандартные ФЛ кроме ЭК*/    when 172 then if not v-express and not v-ur then v-deval = v-bal6 * rate[txb.lon.crc].
        /* сомн. 1-ой кат */            when 35 then if v-lonstat = 2 then v-deval = v-bal6 * rate[txb.lon.crc].
     /* сомн. 1-ой кат ФЛ кроме ЭК*/    when 173 then if v-lonstat = 2 and not v-express and not v-ur then v-deval = v-bal6 * rate[txb.lon.crc].
        /* сомн. 2-ой кат */            when 36 then if v-lonstat = 3 then v-deval = v-bal6 * rate[txb.lon.crc].
    /* сомн. 2-ой кат ФЛ кроме ЭК */    when 240 then if v-lonstat = 3 and not v-express and not v-ur then v-deval = v-bal6 * rate[txb.lon.crc].
        /* сомн. 3-ой кат */            when 37 then if v-lonstat = 4 then v-deval = v-bal6 * rate[txb.lon.crc].
    /* сомн. 3-ой кат ФЛ кроме ЭК */    when 241 then if v-lonstat = 4 and not v-express and not v-ur then v-deval = v-bal6 * rate[txb.lon.crc].
        /* сомн. 4-ой кат */            when 38 then if v-lonstat = 5 then v-deval = v-bal6 * rate[txb.lon.crc].
    /* сомн. 4-ой кат ФЛ кроме ЭК */    when 242 then if v-lonstat = 5 and not v-express and not v-ur then v-deval = v-bal6 * rate[txb.lon.crc].        
        /* сомн. 5-ой кат */            when 39 then if v-lonstat = 6 then v-deval = v-bal6 * rate[txb.lon.crc].
     /* сомн. 5-ой кат ФЛ кроме ЭК*/    when 203 then if v-lonstat = 6 and not v-express and not v-ur then v-deval = v-bal6 * rate[txb.lon.crc].        
        /* безнадежные */               when 40 then if v-lonstat = 7 then v-deval = v-bal6 * rate[txb.lon.crc].
        /* безнадежные ФЛ кроме ЭК*/    when 174 then if v-lonstat = 7 and not v-express and not v-ur then v-deval = v-bal6 * rate[txb.lon.crc].                
        
        /* все провизии по ЭК */        when 49 then if v-express then v-deval = v-bal6 * rate[txb.lon.crc].
        /* стандартные ЭК */            when 50 then if v-express and v-lonstat = 1 then v-deval = v-bal6 * rate[txb.lon.crc].
  /*стандартные экспресс стандартный*/  when 175 then if v-express and v-lonstat = 1 and txb.loncon.lcnt matches "*ДК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*стандартные экспресс льготный*/     when 176 then if v-express and v-lonstat = 1 and txb.loncon.lcnt matches "*ЛК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*стандартные экспресс коммерсант*/   when 177 then if v-express and v-lonstat = 1 and txb.loncon.lcnt matches "*ПК*" then v-deval = v-bal6 * rate[txb.lon.crc].
        /* сомн. ЭК 1-ой кат */         when 51 then if v-express and v-lonstat = 2 then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 1-ой кат стандартный*/     when 178 then if v-express and v-lonstat = 2 and txb.loncon.lcnt matches "*ДК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 1-ой кат льготный*/        when 179 then if v-express and v-lonstat = 2 and txb.loncon.lcnt matches "*ЛК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 1-ой кат коммерсант*/      when 180 then if v-express and v-lonstat = 2 and txb.loncon.lcnt matches "*ПК*" then v-deval = v-bal6 * rate[txb.lon.crc].
        /* сомн. ЭК 2-ой кат */         when 52 then if v-express and v-lonstat = 3 then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 2-ой кат эк стандартный*/  when 243 then if v-express and v-lonstat = 3 and txb.loncon.lcnt matches "*ДК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
  /*сомн. ЭК 2-ой кат эк льготный*/     when 244 then if v-express and v-lonstat = 3 and txb.loncon.lcnt matches "*ЛК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
  /*сомн. ЭК 2-ой кат эк коммерсант*/   when 245 then if v-express and v-lonstat = 3 and txb.loncon.lcnt matches "*ПК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
        /* сомн. ЭК 3-ой кат */         when 53 then if v-express and v-lonstat = 4 then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 3-ой кат эк стандартный*/  when 246 then if v-express and v-lonstat = 4 and txb.loncon.lcnt matches "*ДК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
  /*сомн. ЭК 3-ой кат эк льготный*/     when 247 then if v-express and v-lonstat = 4 and txb.loncon.lcnt matches "*ЛК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
  /*сомн. ЭК 3-ой кат эк коммерсант*/   when 248 then if v-express and v-lonstat = 4 and txb.loncon.lcnt matches "*ПК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
        /* сомн. ЭК 4-ой кат */         when 54 then if v-express and v-lonstat = 5 then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 4-ой кат эк стандартный*/  when 249 then if v-express and v-lonstat = 5 and txb.loncon.lcnt matches "*ДК*" then v-deval = v-bal6 * rate[txb.lon.crc].                
  /*сомн. ЭК 4-ой кат эк льготный*/     when 250 then if v-express and v-lonstat = 5 and txb.loncon.lcnt matches "*ЛК*" then v-deval = v-bal6 * rate[txb.lon.crc].                
  /*сомн. ЭК 4-ой кат эк коммерсант*/   when 251 then if v-express and v-lonstat = 5 and txb.loncon.lcnt matches "*ПК*" then v-deval = v-bal6 * rate[txb.lon.crc].                
        /* сомн. ЭК 5-ой кат */         when 55 then if v-express and v-lonstat = 6 then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 5-ой кат стандартный*/     when 181 then if v-express and v-lonstat = 6 and txb.loncon.lcnt matches "*ДК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 5-ой кат льготный*/        when 182 then if v-express and v-lonstat = 6 and txb.loncon.lcnt matches "*ЛК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*сомн. ЭК 5-ой кат коммерсант*/      when 183 then if v-express and v-lonstat = 6 and txb.loncon.lcnt matches "*ПК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
        /* безнадежные ЭК */            when 56 then if v-express and v-lonstat = 7 then v-deval = v-bal6 * rate[txb.lon.crc].
  /*безнадежные ЭК стандартный*/        when 184 then if v-express and v-lonstat = 7 and txb.loncon.lcnt matches "*ДК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*безнадежные ЭК льготный*/           when 185 then if v-express and v-lonstat = 7 and txb.loncon.lcnt matches "*ЛК*" then v-deval = v-bal6 * rate[txb.lon.crc].
  /*безнадежные ЭК коммерсант*/         when 186 then if v-express and v-lonstat = 7 and txb.loncon.lcnt matches "*ПК*" then v-deval = v-bal6 * rate[txb.lon.crc].        
        
        
        /* количество */                when 41 then if v-bal6 > 0 then v-deval = 1.
        /* кол-во стандартные */        when 42 then if v-lonstat = 1 and v-bal6 > 0 then v-deval = 1.
        /* стандартные ФЛ кроме ЭК*/    when 187 then if not v-express and not v-ur and v-bal6 > 0 then v-deval = 1.        
        /* кол-во сомн. 1-ой кат */     when 43 then if v-lonstat = 2 and v-bal6 > 0 then v-deval = 1.
        /* сомн. 1-ой кат ФЛ кроме ЭК*/ when 188 then if v-lonstat = 2 and not v-express and not v-ur and v-bal6 > 0 then v-deval = 1.        
        /* кол-во сомн. 2-ой кат */     when 44 then if v-lonstat = 3 and v-bal6 > 0 then v-deval = 1.
/* кол-во сомн. 2-ой кат ФЛ кроме ЭК */ when 252 then if v-lonstat = 3 and not v-express and not v-ur and v-bal6 > 0 then v-deval = 1.
        /* кол-во сомн. 3-ой кат */     when 45 then if v-lonstat = 4 and v-bal6 > 0 then v-deval = 1.
/* кол-во сомн. 3-ой кат ФЛ кроме ЭК */ when 253 then if v-lonstat = 4 and not v-express and not v-ur and v-bal6 > 0 then v-deval = 1.        
        /* кол-во сомн. 4-ой кат */     when 46 then if v-lonstat = 5 and v-bal6 > 0 then v-deval = 1.
/* кол-во сомн. 4-ой кат ФЛ кроме ЭК */ when 254 then if v-lonstat = 5 and not v-express and not v-ur and v-bal6 > 0 then v-deval = 1.        
        /* кол-во сомн. 5-ой кат */     when 47 then if v-lonstat = 6 and v-bal6 > 0 then v-deval = 1.
     /* сомн. 5-ой кат ФЛ кроме ЭК*/    when 189 then if v-lonstat = 6 and not v-express and not v-ur and v-bal6 > 0 then v-deval = 1.                  
        /* кол-во безнадежные */        when 48 then if v-lonstat = 7 and v-bal6 > 0 then v-deval = 1.
        /* безнадежные ФЛ кроме ЭК*/    when 190 then if v-lonstat = 7 and not v-express and not v-ur and v-bal6 > 0 then v-deval = 1.                
     
        /* количество ЭК */             when 57 then if v-express and v-bal6 > 0 then v-deval = 1.
        /* кол-во стандартные ЭК */     when 58 then if v-express and v-lonstat = 1 and v-bal6 > 0 then v-deval = 1.
  /*стандартные экспресс стандартный*/  when 191 then if v-express and v-lonstat = 1 and txb.loncon.lcnt matches "*ДК*" and v-bal6 > 0 then v-deval = 1.
  /*стандартные экспресс льготный*/     when 192 then if v-express and v-lonstat = 1 and txb.loncon.lcnt matches "*ЛК*" and v-bal6 > 0 then v-deval = 1.
  /*стандартные экспресс коммерсант*/   when 193 then if v-express and v-lonstat = 1 and txb.loncon.lcnt matches "*ПК*" and v-bal6 > 0 then v-deval = 1.
        /* кол-во сомн. ЭК 1-ой кат */  when 59 then if v-express and v-lonstat = 2 and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 1-ой кат стандартный*/     when 194 then if v-express and v-lonstat = 2 and txb.loncon.lcnt matches "*ДК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 1-ой кат льготный*/        when 195 then if v-express and v-lonstat = 2 and txb.loncon.lcnt matches "*ЛК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 1-ой кат коммерсант*/      when 196 then if v-express and v-lonstat = 2 and txb.loncon.lcnt matches "*ПК*" and v-bal6 > 0 then v-deval = 1.        
        /* кол-во сомн. ЭК 2-ой кат */  when 60 then if v-express and v-lonstat = 3 and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 2-ой кат стандартный*/     when 255 then if v-express and v-lonstat = 3 and txb.loncon.lcnt matches "*ДК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 2-ой кат льготный*/        when 256 then if v-express and v-lonstat = 3 and txb.loncon.lcnt matches "*ЛК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 2-ой кат коммерсант*/      when 257 then if v-express and v-lonstat = 3 and txb.loncon.lcnt matches "*ПК*" and v-bal6 > 0 then v-deval = 1.        
        /* кол-во сомн. ЭК 3-ой кат */  when 61 then if v-express and v-lonstat = 4 and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 3-ой кат стандартный*/     when 258 then if v-express and v-lonstat = 4 and txb.loncon.lcnt matches "*ДК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 3-ой кат льготный*/        when 259 then if v-express and v-lonstat = 4 and txb.loncon.lcnt matches "*ЛК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 3-ой кат коммерсант*/      when 260 then if v-express and v-lonstat = 4 and txb.loncon.lcnt matches "*ПК*" and v-bal6 > 0 then v-deval = 1.                
        /* кол-во сомн. ЭК 4-ой кат */  when 62 then if v-express and v-lonstat = 5 and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 4-ой кат стандартный*/     when 261 then if v-express and v-lonstat = 5 and txb.loncon.lcnt matches "*ДК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 4-ой кат льготный*/        when 262 then if v-express and v-lonstat = 5 and txb.loncon.lcnt matches "*ЛК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 4-ой кат коммерсант*/      when 263 then if v-express and v-lonstat = 5 and txb.loncon.lcnt matches "*ПК*" and v-bal6 > 0 then v-deval = 1.        
        /* кол-во сомн. ЭК 5-ой кат */  when 63 then if v-express and v-lonstat = 6 and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 5-ой кат стандартный*/     when 197 then if v-express and v-lonstat = 6 and txb.loncon.lcnt matches "*ДК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 5-ой кат льготный*/        when 198 then if v-express and v-lonstat = 6 and txb.loncon.lcnt matches "*ЛК*" and v-bal6 > 0 then v-deval = 1.
  /*сомн. ЭК 5-ой кат коммерсант*/      when 199 then if v-express and v-lonstat = 6 and txb.loncon.lcnt matches "*ПК*" and v-bal6 > 0 then v-deval = 1.        
        /* кол-во безнадежные ЭК */     when 64 then if v-express and v-lonstat = 7 and v-bal6 > 0 then v-deval = 1.
  /*безнадежные ЭК стандартный*/        when 200 then if v-express and v-lonstat = 7 and txb.loncon.lcnt matches "*ДК*" and v-bal6 > 0 then v-deval = 1.
  /*безнадежные ЭК льготный*/           when 201 then if v-express and v-lonstat = 7 and txb.loncon.lcnt matches "*ЛК*" and v-bal6 > 0 then v-deval = 1.
  /*безнадежные ЭК коммерсант*/         when 202 then if v-express and v-lonstat = 7 and txb.loncon.lcnt matches "*ПК*" and v-bal6 > 0 then v-deval = 1.        
        
    end case.
end procedure.

/* ------ просроченные кредиты ---------- */

procedure creddebt:
    def output parameter v-deval as deci no-undo.
    def var v-sum as deci no-undo.
    v-sum = v-bal1 + v-bal7.
    def var v-var as deci no-undo.
    
    /*Ищем номер контаркта для экспресс кредитов*/
    if v-express then find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error. 
        
    case valspr.code:
        /* сумма ОД просроч. кредитов */                               when 135 then if v-daymax > 0 then v-deval = v-sum * rate[txb.lon.crc].
        /* сумма ОД просроч. кредитов с просрочкой до 30 дней */       when 65 then if v-daymax > 0 and v-daymax <= 30 then v-deval = v-sum * rate[txb.lon.crc].
        
        /* сумма --- до 30 дней ФЛ автокредит*/    when 204 then if (txb.lon.grp = 25 or txb.lon.grp = 65) and v-daymax > 0 and v-daymax <= 30 then v-deval = v-sum * rate[txb.lon.crc].
        /* сумма --- до 30 дней ФЛ ипотека*/       when 205 then if (txb.lon.grp = 27 or txb.lon.grp = 67) and v-daymax > 0 and v-daymax <= 30 then v-deval = v-sum * rate[txb.lon.crc].
        /* сумма --- до 30 дней ФЛ ипотека*/       when 206 then if (txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66) and v-daymax > 0 and v-daymax <= 30 then v-deval = v-sum * rate[txb.lon.crc].      

        /* сумма ОД просроч. кредитов с просрочкой от 30 до 90 дней */ when 66 then if v-daymax > 30 and v-daymax <= 90 then v-deval = v-sum * rate[txb.lon.crc].
 
        /* сумма --- от 30 до 90 дней ФЛ автокредит*/    when 207 then if (txb.lon.grp = 25 or txb.lon.grp = 65) and v-daymax > 30 and v-daymax <= 90 then v-deval = v-sum * rate[txb.lon.crc].
        /* сумма --- от 30 до 90 дней ФЛ ипотека*/       when 208 then if (txb.lon.grp = 27 or txb.lon.grp = 67) and v-daymax > 30 and v-daymax <= 90 then v-deval = v-sum * rate[txb.lon.crc].
        /* сумма --- от 30 до 90 дней ФЛ ипотека*/       when 209 then if (txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66) and v-daymax > 30 and v-daymax <= 90 then v-deval = v-sum * rate[txb.lon.crc].      
 
        /* сумма ОД просроч. кредитов с просрочкой свыше 90 дней */    when 67 then if v-daymax > 90 then v-deval = v-sum * rate[txb.lon.crc].

        /* сумма --- свыше 90 дней ФЛ автокредит*/    when 210 then if (txb.lon.grp = 25 or txb.lon.grp = 65) and v-daymax > 90 then v-deval = v-sum * rate[txb.lon.crc].
        /* сумма --- свыше 90 дней ФЛ ипотека*/       when 211 then if (txb.lon.grp = 27 or txb.lon.grp = 67) and v-daymax > 90 then v-deval = v-sum * rate[txb.lon.crc].
        /* сумма --- свыше 90 дней ФЛ ипотека*/       when 212 then if (txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66) and v-daymax > 90 then v-deval = v-sum * rate[txb.lon.crc].      

        /* кредиты с законченным сроком действия договора */           when 68 then if v-duedt < v-dt and v-sum > 0 then v-deval = v-sum * rate[txb.lon.crc].
        
        /* кол-во --- */                  when 136 then if v-daymax > 0 then v-deval = 1.
        /* кол-во --- до 30 дней */       when 69 then if v-sum > 0 and v-daymax > 0 and v-daymax <= 30 then v-deval = 1.    

        /* количество --- до 30 дней ФЛ автокредит*/    when 213 then if (txb.lon.grp = 25 or txb.lon.grp = 65) and v-sum > 0 and v-daymax > 0 and v-daymax <= 30 then v-deval = 1.
        /* количество --- до 30 дней ФЛ ипотека*/       when 214 then if (txb.lon.grp = 27 or txb.lon.grp = 67) and v-sum > 0 and v-daymax > 0 and v-daymax <= 30 then v-deval = 1.
        /* количество --- до 30 дней ФЛ ипотека*/       when 215 then if (txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66) and v-sum > 0 and v-daymax > 0 and v-daymax <= 30 then v-deval = 1.      
        
        /* кол-во --- от 30 до 90 дней */ when 70 then if v-sum > 0 and v-daymax > 30 and v-daymax <= 90 then v-deval = 1.
        
        /* количество --- от 30 до 90 дней ФЛ автокредит*/    when 216 then if (txb.lon.grp = 25 or txb.lon.grp = 65) and v-sum > 0 and v-daymax > 30 and v-daymax <= 90 then v-deval = 1.
        /* количество --- от 30 до 90 дней ФЛ ипотека*/       when 217 then if (txb.lon.grp = 27 or txb.lon.grp = 67) and v-sum > 0 and v-daymax > 30 and v-daymax <= 90 then v-deval = 1.
        /* количество --- от 30 до 90 дней ФЛ ипотека*/       when 218 then if (txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66) and v-sum > 0 and v-daymax > 30 and v-daymax <= 90 then v-deval = 1.      
        
        /* кол-во --- свыше 90 дней */    when 71 then if v-sum > 0 and v-daymax > 90 then v-deval = 1.

        /* количество --- свыше 90 дней ФЛ автокредит*/    when 219 then if (txb.lon.grp = 25 or txb.lon.grp = 65) and v-sum > 0 and v-daymax > 90 then v-deval = 1.
        /* количество --- свыше 90 дней ФЛ ипотека*/       when 220 then if (txb.lon.grp = 27 or txb.lon.grp = 67) and v-sum > 0 and v-daymax > 90 then v-deval = 1.
        /* количество --- свыше 90 дней ФЛ ипотека*/       when 221 then if (txb.lon.grp = 20 or txb.lon.grp = 60 or txb.lon.grp = 26 or txb.lon.grp = 66) and v-sum > 0 and v-daymax > 90 then v-deval = 1.      

        /* кол-во --- истек договор */    when 72 then if v-duedt < v-dt and v-sum > 0 then v-deval = 1.
        
        /* то же самое по ЭК */
        when 137 then if v-express and v-daymax > 0 then v-deval = v-sum * rate[txb.lon.crc].
        when 73 then if v-express and v-daymax > 0 and v-daymax <= 30 then v-deval = v-sum * rate[txb.lon.crc].
/* экспресс стандартный*/   when 222 then if v-express and txb.loncon.lcnt matches "*ДК*" and v-daymax > 0 and v-daymax <= 30 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс льготный*/      when 223 then if v-express and txb.loncon.lcnt matches "*ЛК*" and v-daymax > 0 and v-daymax <= 30 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс коммерсант*/    when 224 then if v-express and txb.loncon.lcnt matches "*ПК*" and v-daymax > 0 and v-daymax <= 30 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].       
        when 74 then if v-express and v-daymax > 30 and v-daymax <= 90 then v-deval = v-sum * rate[txb.lon.crc].
/* экспресс стандартный*/   when 225 then if v-express and txb.loncon.lcnt matches "*ДК*" and v-daymax > 30 and v-daymax <= 90 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс льготный*/      when 226 then if v-express and txb.loncon.lcnt matches "*ЛК*" and v-daymax > 30 and v-daymax <= 90 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс коммерсант*/    when 227 then if v-express and txb.loncon.lcnt matches "*ПК*" and v-daymax > 30 and v-daymax <= 90 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        when 75 then if v-express and v-daymax > 90 then v-deval = v-sum * rate[txb.lon.crc].
/* экспресс стандартный*/   when 228 then if v-express and txb.loncon.lcnt matches "*ДК*" and v-daymax > 90 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс льготный*/      when 229 then if v-express and txb.loncon.lcnt matches "*ЛК*" and v-daymax > 90 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
/* экспресс коммерсант*/    when 230 then if v-express and txb.loncon.lcnt matches "*ПК*" and v-daymax > 90 then v-deval = (v-bal1 + v-bal7) * rate[txb.lon.crc].
        when 76 then if v-express and v-duedt < v-dt and v-sum > 0 then v-deval = v-sum * rate[txb.lon.crc].
        
        when 138 then if v-express and v-daymax > 0 then v-deval = 1.
        when 77 then if v-express and v-sum > 0 and v-daymax > 0 and v-daymax <= 30 then v-deval = 1.
/* экспресс стандартный*/   when 231 then if v-express and txb.loncon.lcnt matches "*ДК*" and v-daymax > 0 and v-daymax <= 30 and v-sum > 0 then v-deval = 1.
/* экспресс льготный*/      when 232 then if v-express and txb.loncon.lcnt matches "*ЛК*" and v-daymax > 0 and v-daymax <= 30 and v-sum > 0 then v-deval = 1.
/* экспресс коммерсант*/    when 233 then if v-express and txb.loncon.lcnt matches "*ПК*" and v-daymax > 0 and v-daymax <= 30 and v-sum > 0 then v-deval = 1.       
        when 78 then if v-express and v-sum > 0 and v-daymax > 30 and v-daymax <= 90 then v-deval = 1.
/* экспресс стандартный*/   when 234 then if v-express and txb.loncon.lcnt matches "*ДК*" and v-daymax > 30 and v-daymax <= 90 and v-sum > 0 then v-deval = 1.
/* экспресс льготный*/      when 235 then if v-express and txb.loncon.lcnt matches "*ЛК*" and v-daymax > 30 and v-daymax <= 90 and v-sum > 0 then v-deval = 1.
/* экспресс коммерсант*/    when 236 then if v-express and txb.loncon.lcnt matches "*ПК*" and v-daymax > 30 and v-daymax <= 90 and v-sum > 0 then v-deval = 1.       
        when 79 then if v-express and v-sum > 0 and v-daymax > 90 then v-deval = 1.
/* экспресс стандартный*/   when 237 then if v-express and txb.loncon.lcnt matches "*ДК*" and v-daymax > 90 and v-sum > 0 then v-deval = 1.
/* экспресс льготный*/      when 238 then if v-express and txb.loncon.lcnt matches "*ЛК*" and v-daymax > 90 and v-sum > 0 then v-deval = 1.
/* экспресс коммерсант*/    when 239 then if v-express and txb.loncon.lcnt matches "*ПК*" and v-daymax > 90 and v-sum > 0 then v-deval = 1.       
        when 80 then if v-express and v-duedt < v-dt and v-sum > 0 then v-deval = 1.
        
        /* просрочки */
        /* пр. ОД */        when 81 then v-deval = v-bal7 * rate[txb.lon.crc].
        /* пр. %% */        when 82 then v-deval = v-bal9 * rate[txb.lon.crc].
        /* внесист. %% */   when 83 then v-deval = v-bal4 * rate[txb.lon.crc].
        /* пеня */          when 84 then v-deval = v-bal16 * rate[txb.lon.crc].
        /* внесист. пеня */ when 85 then v-deval = v-bal5 * rate[txb.lon.crc].
        /* спис.ОД */       when 86 then v-deval = v-bal13 * rate[txb.lon.crc].
        /* спис.ОД - пог */ when 139 then do:
                                v-deval = 0.
                                for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.lev = 13 and txb.lonres.dc = 'C' no-lock:
                                    v-deval = v-deval + txb.lonres.amt * rate[txb.lon.crc].
                                end.
                            end.
        /* спис.%% */       when 87 then v-deval = v-bal14 * rate[txb.lon.crc].
        /* спис.%% - пог */ when 140 then do:
                                v-deval = 0.
                                for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.lev = 14 and txb.lonres.dc = 'C' no-lock:
                                    v-deval = v-deval + txb.lonres.amt * rate[txb.lon.crc].
                                end.
                            end.
        /* спис.пеня */     when 88 then v-deval = v-bal30 * rate[txb.lon.crc].
        /* спис.пеня пог */ when 141 then do:
                                v-deval = 0.
                                for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.lev = 30 and txb.lonres.dc = 'C' no-lock:
                                    v-deval = v-deval + txb.lonres.amt.
                                end.
                            end.
        
        /* то же по ЭК */
        /* пр. ОД */        when 89 then if v-express then v-deval = v-bal7 * rate[txb.lon.crc].
        /* пр. %% */        when 90 then if v-express then v-deval = v-bal9 * rate[txb.lon.crc].
        /* внесист. %% */   when 91 then if v-express then v-deval = v-bal4 * rate[txb.lon.crc].
        /* пеня */          when 92 then if v-express then v-deval = v-bal16 * rate[txb.lon.crc].
        /* внесист. пеня */ when 93 then if v-express then v-deval = v-bal5 * rate[txb.lon.crc].
        /* спис. ОД */      when 94 then if v-express then v-deval = v-bal13 * rate[txb.lon.crc].
        /* спис.ОД - пог */ when 142 then
                                if v-express then
                                do:
                                v-deval = 0.
                                for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.lev = 13 and txb.lonres.dc = 'C' no-lock:
                                    v-deval = v-deval + txb.lonres.amt * rate[txb.lon.crc].
                                end.
                            end.
        /* спис. %% */      when 95 then if v-express then v-deval = v-bal14 * rate[txb.lon.crc].
        /* спис.%% - пог */ when 143 then
                                if v-express then
                                do:
                                v-deval = 0.
                                for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.lev = 14 and txb.lonres.dc = 'C' no-lock:
                                    v-deval = v-deval + txb.lonres.amt * rate[txb.lon.crc].
                                end.
                            end.
        /* спис. пеня */    when 96 then if v-express then v-deval = v-bal30 * rate[txb.lon.crc].
        /* спис.пеня пог */ when 144 then
                                if v-express then
                                do:
                                v-deval = 0.
                                for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= v-begday and txb.lonres.lev = 30 and txb.lonres.dc = 'C' no-lock:
                                    v-deval = v-deval + txb.lonres.amt.
                                end.
                            end.
        
    end case.
end.

/* доходность */

procedure creddoh:
    def output parameter v-deval as deci no-undo.
    case valspr.code:
        /* начисленные %% на дату */
        /* все */        when 97 then v-deval = v-prc_nach * rate[txb.lon.crc].
        /* KZT */        when 98 then if txb.lon.crc = 1 then v-deval = v-prc_nach.
        /* USD */        when 99 then if txb.lon.crc = 2 then v-deval = v-prc_nach.
        /* EUR */        when 100 then if txb.lon.crc = 3 then v-deval = v-prc_nach.
        /* ЮЛ */         when 101 then if v-ur then v-deval = v-prc_nach * rate[txb.lon.crc].
        /* ФЛ */         when 102 then if not v-ur then v-deval = v-prc_nach * rate[txb.lon.crc].
        /* краткосроч */ when 103 then if v-kr then v-deval = v-prc_nach * rate[txb.lon.crc].
        /* долгосроч */  when 104 then if not v-kr then v-deval = v-prc_nach * rate[txb.lon.crc].
        /* express */    when 105 then if v-express then v-deval = v-prc_nach * rate[txb.lon.crc].
        /* полученные %% на дату */
        /* все */        when 106 then v-deval = v-prc_pog * rate[txb.lon.crc].
        /* KZT */        when 107 then if txb.lon.crc = 1 then v-deval = v-prc_pog.
        /* USD */        when 108 then if txb.lon.crc = 2 then v-deval = v-prc_pog.
        /* EUR */        when 109 then if txb.lon.crc = 3 then v-deval = v-prc_pog.
        /* ЮЛ */         when 110 then if v-ur then v-deval = v-prc_pog * rate[txb.lon.crc].
        /* ФЛ */         when 111 then if not v-ur then v-deval = v-prc_pog * rate[txb.lon.crc].
        /* краткосроч */ when 112 then if v-kr then v-deval = v-prc_pog * rate[txb.lon.crc].
        /* долгосроч */  when 113 then if not v-kr then v-deval = v-prc_pog * rate[txb.lon.crc].
        /* express */    when 114 then if v-express then v-deval = v-prc_pog * rate[txb.lon.crc].
        
        /* начисленная пеня на дату */
        /* все */        when 115 then v-deval = v-pen_nach.
        /* KZT */        when 116 then if txb.lon.crc = 1 then v-deval = v-pen_nach.
        /* USD */        when 117 then if txb.lon.crc = 2 then v-deval = v-pen_nach.
        /* EUR */        when 118 then if txb.lon.crc = 3 then v-deval = v-pen_nach.
        /* ЮЛ */         when 119 then if v-ur then v-deval = v-pen_nach.
        /* ФЛ */         when 120 then if not v-ur then v-deval = v-pen_nach.
        /* краткосроч */ when 121 then if v-kr then v-deval = v-pen_nach.
        /* долгосроч */  when 122 then if not v-kr then v-deval = v-pen_nach.
        /* express */    when 123 then if v-express then v-deval = v-pen_nach.
        /* полученная пеня на дату */
        /* все */        when 124 then v-deval = v-pen_pog.
        /* KZT */        when 125 then if txb.lon.crc = 1 then v-deval = v-pen_pog.
        /* USD */        when 126 then if txb.lon.crc = 2 then v-deval = v-pen_pog.
        /* EUR */        when 127 then if txb.lon.crc = 3 then v-deval = v-pen_pog.
        /* ЮЛ */         when 128 then if v-ur then v-deval = v-pen_pog.
        /* ФЛ */         when 129 then if not v-ur then v-deval = v-pen_pog.
        /* краткосроч */ when 130 then if v-kr then v-deval = v-pen_pog.
        /* долгосроч */  when 131 then if not v-kr then v-deval = v-pen_pog.
        /* express */    when 132 then if v-express then v-deval = v-pen_pog.
        
        /*
        -- фонд покрытия кредитных рисков --
        when 133 then do:
            if v-express and txb.lon.rdt < v-dt and txb.lon.rdt >= v-begday then do:
                find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
                if avail pkanketa then v-deval = pkanketa.sumcom.
            end.
        end.
        -- комиссия за обслуживание кредита --
        when 134 then do:
            if v-express then do:
                v-deval = 0.
                for each txb.jl where txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'D' and txb.jl.jdt < v-dt and txb.jl.lev = 1 no-lock:
                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                    if b-jl.gl = 460712 then v-deval = v-deval + txb.jl.dam.
                end.
            end.
        end.
        */
    end.
end.

procedure creddohgl:
    def output parameter v-deval as deci no-undo.
    case valspr.code:
        /* комиссия за выдачу кредита */ when 133 then v-deval = glsum (442900, v-dt, 1, -1, '').
        /* комиссия за обслуж кредита */ when 134 then v-deval = glsum (460712, v-dt, 1, -1, '').
    end.
    /*
    message s-ourbank + " " + string(valspr.code) + " " + trim(string(v-deval,">>>,>>>,>>>,>>9.99")) view-as alert-box.
    */
end.