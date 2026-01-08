;; 注释
((comment) @comment)

;; 函数名
((function_declaration
    name: (identifier) @function))

;; 结构体类型
((type_spec
    name: (type_identifier) @type))

;; 字符串
((interpreted_string_literal) @string)
((raw_string_literal) @string)

;; 数字
((int_literal) @number)
((float_literal) @number)
((imaginary_literal) @number)


;; 局部变量短声明 x, y := ...
((short_var_declaration
  (expression_list
    (identifier) @variable.definition)))
;; var 声明
((var_spec
  (identifier) @variable.definition))

;; 函数参数
((parameter_declaration
    name: (identifier) @variable.parameter))

;; 常量高亮
(const_spec
    name: (identifier) @constant)


;; 操作符，括号标点
"=" @operator
"+" @operator
"-" @operator
"*" @operator
"/" @operator
"!" @operator
"%" @operator
"^" @operator
"&" @operator
"|" @operator
"," @operator
"." @operator
";" @operator
":" @operator
"==" @operator
"!=" @operator
"<" @operator
">" @operator
"<=" @operator
">=" @operator
":=" @operator

;; 括号
"(" @operator
")" @operator
"[" @operator
"]" @operator
"{" @operator
"}" @operator

