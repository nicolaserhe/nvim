;inherits: c

;; ============================================================
;; cpp 高亮：继承 c 的全套查询（含上游 + 用户自定义）
;; 此文件仅追加 C++ 特有节点的捕获。
;;
;; 颜色映射在 lua/config/highlights.lua（Tonsky × Dracula）。
;; ============================================================

;; ──────────────────────────────────────────────────────────
;; 1. nullptr → @constant.builtin（紫）
;; C++ 特有；tree-sitter-cpp 把 nullptr 节点命名为 (null)
;; NULL / true / false 已由继承的 c queries 覆盖
;; ──────────────────────────────────────────────────────────
((null) @constant.builtin)

;; ──────────────────────────────────────────────────────────
;; 2. class / namespace 定义
;; class Foo {}              → Foo 是 @type
;; namespace foo {}          → foo 是引入名字（@variable.definition）
;; ──────────────────────────────────────────────────────────
(class_specifier
  name: (type_identifier) @type)

(namespace_definition
  name: (namespace_identifier) @variable.definition)

;; ──────────────────────────────────────────────────────────
;; 3. 构造 / 析构函数
;; class Foo { Foo(); ~Foo(); };
;; 构造函数名是 type_identifier，析构是 destructor_name
;; ──────────────────────────────────────────────────────────
;; 析构函数（~Foo）→ @function
(destructor_name) @function

;; 构造函数的定义：函数声明的名字位置如果是 type_identifier，按 @function 处理
(function_declarator
  declarator: (qualified_identifier
    name: (identifier) @function))

;; ──────────────────────────────────────────────────────────
;; 4. operator 重载 → @function
;; T operator+(T const& other) { ... }
;; ──────────────────────────────────────────────────────────
(operator_name) @function

;; ──────────────────────────────────────────────────────────
;; 5. template 参数
;; template<typename T>      → T 是 @type
;; template<int N>           → N 是 @variable.definition（值参数）
;; ──────────────────────────────────────────────────────────
(type_parameter_declaration
  (type_identifier) @type)

;; 模板的非类型值参数（template<int N>）走参数定义点
(parameter_declaration
  declarator: (identifier) @variable.parameter)

;; ──────────────────────────────────────────────────────────
;; 6. using 声明 / 别名
;; using Foo = int;          → Foo 是 @type
;; using ns::name;           → 这里 name 是使用，不染
;; ──────────────────────────────────────────────────────────
(alias_declaration
  name: (type_identifier) @type)

;; ──────────────────────────────────────────────────────────
;; 7. lambda 捕获列表中绑定的名字 → @variable.definition
;; [x, &y]() { ... }         → x 和 y 是定义点
;; ──────────────────────────────────────────────────────────
(lambda_capture_specifier
  (identifier) @variable.definition)

;; ──────────────────────────────────────────────────────────
;; 8. 结构化绑定（C++17）
;; auto [x, y] = pair;        → x 和 y 是定义点
;; ──────────────────────────────────────────────────────────
(structured_binding_declarator
  (identifier) @variable.definition)

;; ──────────────────────────────────────────────────────────
;; 9. 引用 declarator 中的 `&` 跟名字同色（类比 C 的指针 `*`）
;; T &x;          → `&` 与 x 同色（@variable.definition）
;; T &foo() { }   → `&` 与 foo 同色（@function）
;; ──────────────────────────────────────────────────────────
((reference_declarator "&" @function)
  (#has-ancestor? @function function_definition))

((reference_declarator "&" @variable.definition)
  (#has-ancestor? @variable.definition field_declaration)
  (#not-has-ancestor? @variable.definition parameter_declaration))

((reference_declarator "&" @variable.parameter)
  (#has-ancestor? @variable.parameter parameter_declaration))

((reference_declarator "&" @variable.definition)
  (#has-ancestor? @variable.definition declaration)
  (#not-has-descendant? @variable.definition function_declarator)
  (#not-has-ancestor? @variable.definition parameter_declaration)
  (#not-has-ancestor? @variable.definition function_definition)
  (#not-has-ancestor? @variable.definition field_declaration))
