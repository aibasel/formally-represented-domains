This is a repository to store PDDL domain files that are extended with a
domain-wide goal and constraints describing which instances are legal for the
domain.

With those extensions the domains comply with the formalism presented in the
paper *C. Grundke, G. Röger, M. Helmert. Formal Representations of Classical
Planning Domains. In Proceedings of the 34th International Conference on
Automated Planning and Scheduling (ICAPS 2024), pp. 239-248. 2024.*


## Domain Syntax

This section only describes the syntax of the extension, i. e. domain-wide
goals and legality constraints. For the general syntax of PDDL domain files
please refer to the definition of PDDL2.2 (*S. Edelkamp, J. Hoffmann. PDDL2.2:
The Language for the Classical Part of the 4th International Planning
Competition. Technical Report 195, University of Freiburg, Department of
Computer Science. 2004.*).

The **legality constraints** use the same syntax as PDDL axioms (which use the
keyword `:derived`) but with the keyword `:axiom` instead. Like the existing
PDDL axioms, legality constraints can define derived predicates. They must
define at least one nullary derived predicate to be used as **legality
predicate**. The truth value of this legality predicate determines if a given
task is legal for the domain or not. Like any other predicate it must be
mentioned in the `:predicates` section. Additionally, there must be a section 
`:legality-predicate` that contains only this predicate to identify it as the
legality predicate.

To specify a **domain-wide goal** add a section `:domain-goal` that contains a
single first-order formula. Same as PDDL's task-specific goals it is satisfied
if a state satisfies the formula of the goal.


## Domains in the Repository

The folders ending with `ipc23-learning` contain domain files that were copied
from the [IPC 2023 learning track benchmark
repository](https://github.com/ipc2023-learning/benchmarks) and extended. The
added legality-constraints and domain-wide goals replicate the constraints and
goal information mentioned implicitly in the instance generators of the IPC 2023
learning track (which are also in the benchmark repository).

**Note on childsnack-ipc23-learning**

The instance generator for childsnack of the IPC 2023 learning track is not
consistent with the base-case instances of the learning track. The generator
produces instances where the number of bread portions, content portions, and
*children* is the same. In the base cases however the number of bread portions,
content portions, and *sandwiches* is the same. The constraints in
`childsnack-ipc23-learning/domain.pddl` model the latter version, i. e. the
number of sandwiches matches the number of bread portions and the number of
content portions.

