module Mapper = struct
  type 'a t = 'a -> string
  type mapper = { map : 'a. 'a Generic.t -> 'a t }

  let unit () = "()"
  let int = string_of_int
  let int32 = Int32.to_string
  let int64 = Int64.to_string
  let float = string_of_float
  let bool = string_of_bool
  let char = String.make 1
  let string x = String.concat "" [ "\""; String.escaped x; "\"" ]
  let bytes x = string (Bytes.to_string x)

  let record self _name fields r1 =
    let fields =
      fields
      |> List.map (fun (Generic.Field.Any field) ->
             let typ = Generic.Field.typ field in
             let show = self.map typ in
             let v = Generic.Field.get r1 field in
             String.concat ""
               [ "  "; Generic.Field.name field; " = "; show v; ";" ])
      |> String.concat "\n"
    in
    String.concat "\n" [ "{ "; fields; "}" ]

  let record' _self _r _r1 = failwith "todo"

  let variant self variant_t variant =
    let (Generic.Variant.Value (constr, args)) =
      Generic.Variant.view variant_t variant
    in
    let constr_name = Generic.Constr.name constr in
    match Generic.Constr.args constr with
    | None -> constr_name
    | Some args_t ->
      let show_args = self.map args_t args in
      String.concat " " [ constr_name; show_args ]

  let abstract self _name (t : 'a Generic.t) x =
    let show = self.map t in
    show x
end

module Map = Generic.Map (Mapper)

let show = Map.map