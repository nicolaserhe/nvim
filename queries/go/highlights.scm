;; ============================================================
;; Go 自定义高亮（Tonsky × Dracula）
;;
;; 颜色映射在 lua/config/highlights.lua；本文件只负责把 Go 语法树节点
;; 捕获到正确的 capture group。
;;
;; 核心捕获组：
;;   @string / @number       → 绿（合并同色）
;;   @comment                → 黄
;;   @function / @function.method / @type / @variable.definition
;;   @variable.parameter     → 青（所有定义点）
;;   @constant.builtin / @boolean → 紫（仅 nil / true / false / iota）
;;   @punctuation.bracket / .delimiter → dim 灰（= 与 := 也归此类）
;;   @operator               → base（仅带计算成分的运算符 + - * / == && 等）
;; ============================================================

;; ── 注释 ────────────────────────────────────────────────────
((comment) @comment)

;; ── 函数 / 方法 定义点 ──────────────────────────────────────
;; 普通函数：func Foo() {}
(function_declaration
    name: (identifier) @function)

;; 方法：func (r *T) Foo() {}
(method_declaration
    name: (field_identifier) @function)

;; 接口里的方法签名：interface { Foo() }
;; 注意：tree-sitter-go 用 method_elem，不是早期的 method_spec
(method_elem
    name: (field_identifier) @function)

;; ── 类型定义点 ──────────────────────────────────────────────
;; type T struct {} / type T int
(type_spec
    name: (type_identifier) @type)

;; type T = U （别名）
(type_alias
    name: (type_identifier) @type)

;; ── 字面量 ──────────────────────────────────────────────────
;; 字符串 + 字符（rune）合并到 @string（绿）
[
  (interpreted_string_literal)
  (raw_string_literal)
  (rune_literal)
] @string

;; 数字字面量（也走绿，与字符串同色）
[
  (int_literal)
  (float_literal)
  (imaginary_literal)
] @number

;; ── 内建常量 → 紫 ───────────────────────────────────────────
;; nil / true / false 在 Go grammar 里是独立节点
((true) @constant.builtin)
((false) @constant.builtin)
((nil) @constant.builtin)

;; iota 是预定义标识符（在 const 块内自增），按内建常量处理
((identifier) @constant.builtin
  (#eq? @constant.builtin "iota"))

;; ── 变量 / 常量 定义点 ──────────────────────────────────────
;; 短声明：x, y := ...
(short_var_declaration
    left: (expression_list
        (identifier) @variable.definition))

;; var 块：var x int / var x = ...
(var_spec
    name: (identifier) @variable.definition)

;; const 块：const Foo = ...（用户定义常量在定义点染青，不染紫）
(const_spec
    name: (identifier) @variable.definition)

;; ── 函数参数 / 可变参数 → 青 ───────────────────────────────
(parameter_declaration
    name: (identifier) @variable.parameter)

(variadic_parameter_declaration
    name: (identifier) @variable.parameter)

;; ── struct field 定义点 ────────────────────────────────────
(field_declaration
    name: (field_identifier) @variable.definition)

;; ── package 名 / import 别名（也是引入名字的位置）──────────
(package_clause
    (package_identifier) @variable.definition)

(import_spec
    name: (package_identifier) @variable.definition)

;; ── 标点 dim 灰 ────────────────────────────────────────────
[
  "(" ")" "[" "]" "{" "}"
] @punctuation.bracket

;; 注意：= 与 := 归 punctuation.delimiter（dim 灰），
;; 因为它们是「绑定」语义而非计算语义，按 Tonsky 当结构符号处理
[
  "," "." ";" ":"
  "="  ":="
] @punctuation.delimiter

;; ── 运算符（dim 灰，与标点同色） ──────────────────────────
;; Tonsky：所有「语法骨架」（标点 + 运算符）统一弱化让标识符凸显
[
  "+"  "-"  "*"  "/"  "%"  "^"  "&"  "|"  "!"  "~"
  "++" "--"
  "==" "!=" "<"  ">"  "<=" ">="
  "+=" "-=" "*=" "/=" "%=" "^=" "&=" "|="
  "<<" ">>" "<<=" ">>="
  "&&" "||" "&^" "&^="
  "<-"
] @operator
