;extends

;; ============================================================
;; c 自定义高亮（叠加在 nvim 内置 c queries 之上）
;;
;; 上游已经覆盖：
;;   - 注释 / 字符串 / 数字 / 字符字面量
;;   - 关键字 / 操作符 / 标点（默认 @punctuation.*）
;;   - type_identifier / type_definition / struct/union/enum 头部
;;   - function_definition / function_declaration 名（@function）
;;   - parameter_declaration（含指针，整子树染 @variable.parameter）
;;   - preproc_def / enumerator / @function.call
;;
;; 此文件只保留两类用户独有定制：
;;   1) declarator 中的 `*` 与名字同色（视觉上 `*name` 当一个整体）
;;   2) 标点 ( ) [ ] { } , . ; : 重分类到 @operator
;;      （Tonsky 风格：让语法骨架统一弱化，不区分 punctuation/bracket）
;;
;; `*` 染色用 #has-ancestor? + #has-descendant? predicate 表达，覆盖
;; 任意指针深度，无需枚举。
;; ============================================================

;; ──────────────────────────────────────────────────────────
;; 1. declarator 中的 `*` 染色
;; ──────────────────────────────────────────────────────────

;; 1a. function_definition 返回指针 → @function（任意深度）
;;     `int **foo() {}` 中所有 `*` 与 foo 同色
((pointer_declarator "*" @function)
  (#has-ancestor? @function function_definition))

;; 1b. field_declaration 中的 `*` → @variable.definition（排除参数嵌套）
;;     `int **field;` 中 `*` 与 field 同色
((pointer_declarator "*" @variable.definition)
  (#has-ancestor? @variable.definition field_declaration)
  (#not-has-ancestor? @variable.definition parameter_declaration))

;; 1c. parameter_declaration 中的 `*` → @variable.parameter
;;     `func(int **x)` 中 `*` 与 x 同色
((pointer_declarator "*" @variable.parameter)
  (#has-ancestor? @variable.parameter parameter_declaration))

;; 1d. declaration 中函数声明返回指针 → @function（任意深度）
;;     `int **foo();` 中 `*` 与 foo 同色
;;     用 #has-descendant? 区分函数声明 vs 普通变量声明
((pointer_declarator "*" @function)
  (#has-ancestor? @function declaration)
  (#has-descendant? @function function_declarator)
  (#not-has-ancestor? @function function_definition)
  (#not-has-ancestor? @function parameter_declaration)
  (#not-has-ancestor? @function field_declaration))

;; 1e. declaration 中变量声明（无 function_declarator 后代）→ @variable.definition
;;     `int **x;` / `int **y = &z;` 中 `*` 与 x/y 同色
((pointer_declarator "*" @variable.definition)
  (#has-ancestor? @variable.definition declaration)
  (#not-has-descendant? @variable.definition function_declarator)
  (#not-has-ancestor? @variable.definition parameter_declaration)
  (#not-has-ancestor? @variable.definition function_definition)
  (#not-has-ancestor? @variable.definition field_declaration))

;; ──────────────────────────────────────────────────────────
;; 字段名归 @variable.definition（覆盖上游的 @property 默认）
;; ──────────────────────────────────────────────────────────
((field_identifier) @variable.definition
  (#has-ancestor? @variable.definition field_declaration)
  (#not-has-ancestor? @variable.definition function_declarator)
  (#not-has-ancestor? @variable.definition parameter_declaration))

;; ──────────────────────────────────────────────────────────
;; 2. 标点保持上游分类
;; 上游已把 ; : , . :: 归 @punctuation.delimiter，把 ( ) [ ] { } 归
;; @punctuation.bracket。highlights.lua 单独 dim 这两组即可，无需重映射。
;; ──────────────────────────────────────────────────────────

;; ──────────────────────────────────────────────────────────
;; 3. = 赋值符 → @punctuation.delimiter（dim 灰，按 Tonsky）
;; 复合赋值 += -= *= /= %= ^= &= |= <<= >>= 保留上游 @operator（带计算）
;; ──────────────────────────────────────────────────────────
"=" @punctuation.delimiter

;; ──────────────────────────────────────────────────────────
;; 4. 内建常量 → @constant.builtin（紫）
;; NULL / true / false 在 C 里通常是 identifier（NULL 来自 stddef.h；
;; true/false 来自 stdbool.h 或 C23 关键字）。用 identifier 谓词捕获，
;; 兼容不同 grammar / 标准。
;; ──────────────────────────────────────────────────────────
((identifier) @constant.builtin
  (#any-of? @constant.builtin "NULL" "true" "false"))

;; ──────────────────────────────────────────────────────────
;; 5. typedef 名 → @type（即使上游已覆盖，显式声明无害）
;; typedef int MyInt;
;; ──────────────────────────────────────────────────────────
(type_definition
  declarator: (type_identifier) @type)

;; ──────────────────────────────────────────────────────────
;; 6. struct / union / enum tag → @type
;; struct Foo {} / enum Color {} 中的 Foo / Color
;; ──────────────────────────────────────────────────────────
(struct_specifier
  name: (type_identifier) @type)

(union_specifier
  name: (type_identifier) @type)

(enum_specifier
  name: (type_identifier) @type)

;; ──────────────────────────────────────────────────────────
;; 7. enum 成员 → @variable.definition
;; enum Color { RED, GREEN, BLUE };  RED/GREEN/BLUE 是定义点
;; ──────────────────────────────────────────────────────────
(enumerator
  name: (identifier) @variable.definition)

;; ──────────────────────────────────────────────────────────
;; 8. 宏定义 → 区分对象宏 / 函数式宏
;; #define FOO 42        → FOO 走 @variable.definition
;; #define MAX(a,b) ...  → MAX 走 @function（行为类似函数定义）
;; ──────────────────────────────────────────────────────────
(preproc_def
  name: (identifier) @variable.definition)

(preproc_function_def
  name: (identifier) @function)

;; ──────────────────────────────────────────────────────────
;; 9. goto label 定义点 → @variable.definition
;; label: do_thing();    label 是引入名字的位置
;; goto label;           label 这里是使用，走 base
;; ──────────────────────────────────────────────────────────
(labeled_statement
  label: (statement_identifier) @variable.definition)

;; ──────────────────────────────────────────────────────────
;; 10. 显式补齐运算符（上游可能漏掉的）→ @operator（dim 灰）
;; 注意：= 已在第 3 节单独归到 @punctuation.delimiter
;; ──────────────────────────────────────────────────────────
[
  "++" "--"
  "~"
  "+"  "-"  "*"  "/"  "%"
  "^"  "&"  "|"  "!"
  "==" "!=" "<"  ">"  "<=" ">="
  "+=" "-=" "*=" "/=" "%=" "^=" "&=" "|="
  "<<" ">>" "<<=" ">>="
  "&&" "||"
  "?"
  "->"
] @operator
