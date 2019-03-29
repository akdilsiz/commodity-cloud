##
#    Copyright 2018 Abdulkadir DILSIZ
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
## 
defprotocol Typeable, do: def typeof(self)
defimpl Typeable, for: Atom, do: def typeof(_), do: "atom"
defimpl Typeable, for: BitString, do: def typeof(_), do: "string"
defimpl Typeable, for: Float, do: def typeof(_), do: "float"
defimpl Typeable, for: Decimal, do: def typeof(_), do: "decimal"
defimpl Typeable, for: Function, do: def typeof(_), do: "Function"
defimpl Typeable, for: Integer, do: def typeof(_), do: "integer"
defimpl Typeable, for: List, do: def typeof(_), do: "list"
defimpl Typeable, for: Map, do: def typeof(_), do: "map"
defimpl Typeable, for: PID, do: def typeof(_), do: "pid"
defimpl Typeable, for: Port, do: def typeof(_), do: "port"
defimpl Typeable, for: Reference, do: def typeof(_), do: "reference"
defimpl Typeable, for: Tuple, do: def typeof(_), do: "tuple"
defimpl Typeable, for: NaiveDateTime, do: def typeof(_), do: "naivedatime"
