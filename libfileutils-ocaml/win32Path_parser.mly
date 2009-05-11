/********************************************************************************/
/*  ocaml-fileutils: files and filenames common operations                      */
/*                                                                              */
/*  Copyright (C) 2003-2009, Sylvain Le Gall                                    */
/*                                                                              */
/*  This library is free software; you can redistribute it and/or modify it     */
/*  under the terms of the GNU Lesser General Public License as published by    */
/*  the Free Software Foundation; either version 2.1 of the License, or (at     */
/*  your option) any later version, with the OCaml static compilation           */
/*  exception.                                                                  */
/*                                                                              */
/*  This library is distributed in the hope that it will be useful, but         */
/*  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  */
/*  or FITNESS FOR A PARTICULAR PURPOSE. See the file COPYING for more          */
/*  details.                                                                    */
/*                                                                              */
/*  You should have received a copy of the GNU Lesser General Public License    */
/*  along with this library; if not, write to the Free Software Foundation,     */
/*  Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA               */
/********************************************************************************/

%{

open FilePath_type;;

%}

%token ROOT_SEPARATOR
%token DOUBLE_DOT
%token DOT
%token <string> IDENT
%token EOF
%token SEPARATOR
%start main_filename 
%type <FilePath_type.filename_part list> main_filename
%start main_path_variable
%type <FilePath_type.filename list> main_path_variable

%%

filename_part_separator:
  SEPARATOR normal_filename_part { $2 }
| EOF                            { [] }
;

end_simple_filename_part:
  IDENT end_simple_filename_part      { add_string $1 $2 }
| DOT end_simple_filename_part        { add_string "." $2 }
| DOUBLE_DOT end_simple_filename_part { add_string ".." $2 }
| filename_part_separator             { begin_string "" $1 }
;

middle_simple_filename_part:
  IDENT end_simple_filename_part      { add_string $1 $2 }
| DOT end_simple_filename_part        { add_string "." $2 }
| DOUBLE_DOT end_simple_filename_part { add_string ".." $2 }
;

begin_simple_filename_part:
  IDENT end_simple_filename_part         { add_string $1 $2 }
| DOT middle_simple_filename_part        { add_string "." $2 }
| DOUBLE_DOT middle_simple_filename_part { add_string ".." $2 }
;

normal_filename_part:
  DOUBLE_DOT filename_part_separator { ParentDir :: $2 }
| DOT filename_part_separator        { (CurrentDir Long) :: $2 }
| filename_part_separator            { (Component "") :: $1 }
| begin_simple_filename_part         { end_string $1 }
;

main_filename:
  IDENT ROOT_SEPARATOR normal_filename_part { (Root $1) :: $3 }
| normal_filename_part                      { $1 }
| EOF                                       { [ (CurrentDir Short) ] }
;

main_path_variable:
  IDENT main_path_variable { $1 :: $2 }
| EOF                      { [] }
;
