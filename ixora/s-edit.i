/* s-edit.i
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*------------------------------------------------------------------------------
  #3.Ievades un redi¦ёЅanas programma
  #4.Ieeja:
     &rz         = "1, ja nevar pievienot ierakstus; 2 - sasniedzot faila
                    beigas, pievieno ierakstu"
     &var        = "c - mainЁgais"
     &file       = "faila v–rds"
     &where      = "meklёЅanas nosacЁjums - komandas fragments"
     &i          = "integer mainЁgais - izmanto programma"
     &j
     &n          = "integer mainЁgais vai konstante - ekr–na rindu skaits"
     &key        = "unik–l– faila atslёga"
     &min-key    = "mainЁgais - satur minim–lo faila atslёgu; formё Ѕeit"
     &max-key    = "mainЁgais - satur maksim–lo atslёgu; formё Ѕeit"
     &frame      = "frame v–rds"
     &postfind   = "programmas fragments pёc atraЅanas - piemёram,
                    papildinform–cijas formёЅana"
     &display    = "attёlojamo mainЁgo saraksts"
     &preupdate  = "programmas fragments pirms redi¦ёЅanas -piemёram,
                    st–vokµa fiksёЅana"
     &update     = "redi¦ёjamie mainЁgie"
     &postupdate = "programmas fragments pёc redi¦ёЅanas - piemёram, kontrole,
                    kopsummu kori¦ёЅana atbilstoЅi izmai‡–m"
     &dispkopa   = "programmas fragments uzkr–t–s inform–cijas apstr–dei"
     &precreate  = "programmas fragments pirms jauna ieraksta pievienoЅanas"
     &postcreate = "programmas fragments pёc jauna ieraksta pievienoЅanas"
     &predelete
     &postdelete
     &end        = "programmas fragments, izejot no programmas"
------------------------------------------------------------------------------*/
readkey pause 0.
clear frame {&frame} all.
find last {&file} use-index {&index} where {&where} no-lock no-error.
if not available {&file}
then do:
     if {&rz} = 1
     then return.
     {&precreate}.
     create {&file}.
     {&postcreate}.
end.
do {&j} = 1 to {&n}:
   {&max-key} = {&file}.{&key}.
   find prev {&file} use-index {&index} where {&where} no-lock no-error.
   if not available {&file}
   then leave.
end.
find first {&file} use-index {&index} where {&where} no-lock.
{&postfind}.
{&min-key} = {&file}.{&key}.
{&i} = 2.
readkey pause 0.
repeat with frame {&frame}:
   display {&display} with frame {&frame}.
   pause 0.
   if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("CURSOR-DOWN") and
      lastkey <> keycode("RETURN") and lastkey <> keycode("F10") and
      lastkey <> keycode("U8") and {&i} < {&n}
   then do:
        {&i} = {&i} + 1.
        find next {&file} use-index {&index} where {&where} no-lock no-error.
        if not available {&file}
        then do:
             find last {&file} use-index {&index} where {&where} no-lock.
             {&postfind}.
             display {&display} with frame {&frame}.
             pause 0.
             {&i} = {&n}.
        end.
        else do:
             down with frame {&frame}.
             {&postfind}.
             display {&display} with frame {&frame}.
             pause 0.
             if {&i} = {&n}
             then do:
                  {&dispkopa}.
             end.
        end.
   end.
   if lastkey = keycode("CURSOR-UP")
   then do :
        find prev {&file} use-index {&index} where {&where} exclusive-lock
             no-error.    
        if not available {&file}
        then find first {&file} use-index {&index} where {&where}
             exclusive-lock.
        else up with frame {&frame}.
        {&postfind}.
        display {&display} with frame {&frame}.
        message "Поиск".
        prompt-for {&file}.{&key} go-on
               ("CURSOR-UP" "CURSOR-DOWN" "RETURN" "F10" "U8")
        with frame {&frame}.
        if frame {&frame} {&file}.{&key} entered
        then do:
             if input {&file}.{&key} <> {&file}.{&key}
             then do:
                  {&i} = 2.
                  if input {&file}.{&key} > {&max-key}
                  then find last {&file} use-index {&index} where 
                       {&file}.{&key} = {&max-key} exclusive-lock no-error.
                  else if input {&file}.{&key} < {&min-key}
                  then find first {&file} use-index {&index} where 
                       {&file}.{&key} = {&min-key} exclusive-lock no-error.
                  else find first {&file} use-index {&index}
                       where {&file}.{&key} >= input {&file}.{&key} 
                       exclusive-lock no-error.
                  {&postfind}.
                  readkey pause 0.
                  clear frame {&frame} all.
             end.
        end.
   end.
   if lastkey = keycode("CURSOR-DOWN") or {&i} >= {&n} and
      lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("PF1") and
      lastkey <> keycode("PF4") and lastkey <> keycode("RETURN") and
      lastkey <> keycode("F10") and lastkey <> keycode("U8")
   then do :
        if {&i} >= {&n}
        then do:
             {&dispkopa}.
        end.
        find next {&file} use-index {&index} where {&where} 
             exclusive-lock no-error.
        if not available {&file}
        then do:
             if {&rz} = 1 or lastkey <> keycode("CURSOR-DOWN")
             then do:
                  find last {&file} use-index {&index} where {&where}
                       exclusive-lock.                   
                  {&postfind}.
                  display {&display} with frame {&frame}.
                  message "Поиск".
                  prompt-for {&file}.{&key} go-on
                             ("CURSOR-UP" "CURSOR-DOWN" "RETURN" "F10" "U8")
                  with frame {&frame}.
             end.
             else do:
                  {&precreate}.
                  create {&file}.
                  {&postcreate}.
                  {&postfind}.
                  {&j} = recid({&file}).
                  release {&file}.
                  find first {&file} use-index {&index} where {&where}
                       exclusive-lock.
                  repeat on error undo,retry:
                     find next {&file} use-index {&index} where {&where}
                          exclusive-lock.
                     if recid({&file}) = j
                     then leave.
                  end.
                  down with frame {&frame}. 
                  display {&display} with frame {&frame}.
                  message "Поиск".
                  prompt-for {&file}.{&key} go-on
                             ("CURSOR-UP" "CURSOR-DOWN" "RETURN" "F10" "U8")
                  with frame {&frame}.
             end.
             if frame {&frame} {&file}.{&key} entered
             then do:
                  if input {&file}.{&key} <> {&file}.{&key}
                  then do:
                       {&i} = 2.
                       if input {&file}.{&key} > {&max-key}
                       then find last {&file} use-index {&index}
                            where {&file}.{&key} = {&max-key}
                            exclusive-lock no-error.
                       else if input {&file}.{&key} < {&min-key}
                       then find first {&file} use-index {&index}
                            where {&file}.{&key} = {&min-key}
                            exclusive-lock no-error.
                       else find first {&file} use-index {&index}
                            where {&file}.{&key} >= input {&file}.{&key}
                            exclusive-lock no-error.
                       {&postfind}.
                       readkey pause 0.
                       clear frame {&frame} all.
                  end.
             end.
        end.
        else do:
             down with frame {&frame}.
             {&postfind}.
             display {&display} with frame {&frame}.
             message "Поиск".
             prompt-for {&file}.{&key} go-on
                        ("CURSOR-UP" "CURSOR-DOWN" "RETURN" "F10" "U8")
             with frame {&frame}.
             if frame {&frame} {&file}.{&key} entered
             then do:
                  if input {&file}.{&key} <> {&file}.{&key}
                  then do:
                       {&i} = 2.
                       if input {&file}.{&key} > {&max-key}
                       then find last {&file} use-index {&index}
                            where {&file}.{&key} = {&max-key}
                            exclusive-lock no-error.
                       else if input {&file}.{&key} < {&min-key}
                       then find first {&file} use-index {&index}
                            where {&file}.{&key} = {&min-key}
                            exclusive-lock no-error.
                       else find first {&file} use-index {&index}
                            where {&file}.{&key} >= input {&file}.{&key}
                            exclusive-lock no-error.
                       {&postfind}.
                       readkey pause 0.
                       clear frame {&frame} all.
                  end.
             end.
        end.   
   end.
   if lastkey = keycode("RETURN")
   then do:
        {&preupdate}.
        message "Редактирование".
        {&var} = {&file}.{&key}.
        update {&update} go-on("CURSOR-UP" "CURSOR-DOWN")
               with frame {&frame}.
        {&postupdate}.
        display {&display} with frame {&frame}.
        pause 0.
        {&dispkopa}.
        if {&var} <> {&file}.{&key}
        then do:
             if {&var} = {&min-key}
             then do:
                  {&var} = {&file}.{&key}.
                  find first {&file} use-index {&index} where {&where} no-lock.
                  {&min-key} = {&file}.{&key}.
                  find {&file} use-index {&index} where
                       {&file}.{&key} = {&var} no-lock.
             end.
             {&var} = {&file}.{&key}.
             if {&file}.{&key} < {&min-key}
             then {&min-key} = {&file}.{&key}.
             if {&file}.{&key} > {&max-key}
             then do:
                  find last {&file} use-index {&index} where {&where} no-lock.
                  do {&j} = 1 to {&n}:
                     {&max-key} = {&file}.{&key}.
                     find prev {&file} use-index {&index}
                          where {&where} no-lock no-error.
                     if not available {&file}
                     then leave.
                  end.
             end.
             readkey pause 0.
             clear frame {&frame} all.
             find first {&file} use-index {&index} where
                  {&file}.{&key} = {&var} no-lock.
             do {&j} = 1 to {&n}:
                find next {&file} use-index {&index} 
                     where {&where} no-lock no-error.
                if not available {&file}
                then leave.
             end.
             if {&j} < {&n}
             then do:
                  find last {&file} use-index {&index} where {&where} no-lock.
                  do {&j} = 1 to {&n}:
                     {&var} = {&file}.{&key}.
                     find prev {&file} use-index {&index}
                          where {&where} no-lock no-error.
                     if not available {&file}
                     then leave.
                  end.
             end.
             find first {&file} use-index {&index} where
                  {&file}.{&key} = {&var} exclusive-lock.
             {&i} = 2.
             {&postfind}.
             readkey pause 0.
        end.
        else do:
             message "Поиск".
             prompt-for {&file}.{&key} go-on
                        ("CURSOR-UP" "CURSOR-DOWN" "RETURN" "F10" "U8")
             with frame {&frame}.
             if frame {&frame} {&file}.{&key} entered
             then do:
                  if input {&file}.{&key} <> {&file}.{&key}
                  then do:
                       {&i} = 2.
                       if input {&file}.{&key} > {&max-key}
                       then find last {&file} use-index {&index}
                            where {&file}.{&key} = {&max-key}
                            exclusive-lock no-error.
                       else if input {&file}.{&key} < {&min-key}
                       then find first {&file} use-index {&index}
                            where {&file}.{&key} = {&min-key}
                            exclusive-lock no-error.
                       else find first {&file} use-index {&index}
                            where {&file}.{&key} =
                            input {&file}.{&key} exclusive-lock no-error.
                       {&postfind}.
                       readkey pause 0.
                       clear frame {&frame} all.
                  end.
             end.
        end.
   end.
   if lastkey = keycode("F10") or lastkey = keycode("U8")
   then do:
        if {&rz} = 2
        then do:
             {&var} = "N".
             message "Стереть запись с ключом " {&file}.{&key} " ? (Y/N)"
                     update {&var}.
             if {&var} = "Y"
             then do:
                  {&predelete}.
                  delete {&file}.
                  {&postdelete}.
                  readkey pause 0.
                  clear frame {&frame} all.
                  do {&j} = 1 to {&n}:
                     find next {&file} use-index {&index}
                          where {&where} no-lock no-error.
                     if not available {&file}
                     then leave.
                     if {&j} = 1
                     then {&var} = {&file}.{&key}.
                  end.
                  if {&j} < {&n}
                  then do:
                       find last {&file} use-index {&index}
                            where {&where} no-lock.
                       do {&j} = 1 to {&n}:
                          {&var} = {&file}.{&key}.
                          find prev {&file} use-index {&index}
                               where {&where} no-lock no-error.
                          if not available {&file}
                          then leave.
                       end.
                  end.
                  find first {&file} use-index {&index}
                       where {&file}.{&key} = {&var} exclusive-lock.
                  {&i} = 2.
                  {&postfind}.
                  readkey pause 0.
             end.
             else do:
                  message "Поиск".
                  prompt-for {&file}.{&key} go-on
                             ("CURSOR-UP" "CURSOR-DOWN" "RETURN" "F10" "U8")
                  with frame {&frame}.
                  if frame {&frame} {&file}.{&key} entered
                  then do:
                       if input {&file}.{&key} <> {&file}.{&key}
                       then do:
                            {&i} = 2.
                            if input {&file}.{&key} > {&max-key}
                            then find last {&file} use-index {&index}
                                 where {&file}.{&key} =
                                 {&max-key} exclusive-lock no-error.
                            else if input {&file}.{&key} < {&min-key}
                            then find first {&file} use-index {&index}
                                 where {&file}.{&key} =
                                 {&min-key} exclusive-lock no-error.
                            else find first {&file} use-index {&index}
                                 where {&file}.{&key} =
                                 input {&file}.{&key} exclusive-lock no-error.
                            {&postfind}.
                            readkey pause 0.
                            clear frame {&frame} all.
                       end.
                  end.
             end.
        end.
        else do:
             readkey pause 0.
             {&i} = {&n}.
        end.
   end.
   if lastkey = keycode("PF1") or lastkey = keycode("PF4")
   then leave.
end.
{&end}.
hide frame {&frame}.
