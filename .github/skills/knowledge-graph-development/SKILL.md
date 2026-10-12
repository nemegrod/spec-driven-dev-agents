---
name: knowledge-graph-development
description: How to model, query, implement, review and test an RDF knowledge graph (OWL, SKOS, SPARQL) - modelling principles, the trade-offs to record as decisions, measurable graph quality attributes, query rules, canonical query shapes, graph-store rules and a review checklist. Load before deciding architecture for, designing contracts for, implementing, reviewing or testing anything that touches the ontology, the graph store client, graph queries or aggregation. The intro table says which sections each role applies - Solution Architect, Software Architect, Developer, Code Review Agent, Test Agent - and what each owes.
metadata:
  version: "1.0.0"
---

# Knowledge graph development

A knowledge graph is not a set of tables with foreign keys. The difference changes what is
designed, what is written into the model, how reads are shaped and what a reviewer looks for.
This skill records the rules for a project that stores its data in an RDF repository described by
an OWL ontology. Every section is short enough to read whole.

Governance is unchanged by this skill. The SAD owns decisions, the LLD owns contracts, the
Developer implements contracts. When an existing contract contradicts a rule here, the Developer
does not quietly fix it: it is specification drift, raised to the Software Architect through the
story's Blockers. The project's own facts (its ontology file, its store, its modules, its targets)
are recorded in the project's specification; Section 8 says where.

## When to load this skill, and what each role owes it

The agent files carry no graph rules; this table is the whole contract.

| Role | Load it before | Obligation |
|---|---|---|
| Solution Architect | deciding architecture, trade-offs or quality attributes for anything stored in the graph | Apply Sections 1 to 3: model the domain as typed relationships, not tables; record inference-versus-explicit-statements and fact placement as architectural decisions; state a round-trip and hop bound per read surface in the requirements. Leave query shape to the Software Architect |
| Software Architect | writing or changing any contract that touches the ontology, the graph store client, graph queries or aggregation | Apply Sections 1, 4, 5 and 6. Specify every query in a canonical shape of Section 5. A per-kind or per-node query design is a defect in the LLD, not an option. Record the facts Section 8 lists |
| Developer | editing the ontology, the graph store client, or any module that builds graph queries or aggregates | Follow Sections 4 to 6. If the LLD contract you implement contradicts a rule here (a query per node kind, a whole-kind aggregate for one node, a read through a record node, a copied pattern), it is specification drift: raise it to the Software Architect through the story's Blockers and implement neither side |
| Code Review Agent | reviewing a change that touches the ontology, the graph store client, graph queries, aggregation or any query text | Run the Section 7 checklist in full. Each "no" is a finding at Major severity or above, cited by file and line |
| Test Agent | testing a story whose contract names a round-trip or hop bound | Assert the bound (request count, explicit statements only) as part of the story's validation. Live tests run against the project's test repository only (Section 6) |

---

## 1. Modelling principles

**Model the domain, not the screens.** A class is a kind of thing that exists (an order, a store,
a calendar month). A property is a relationship between things or a fact about one thing.
Enumerated values are named individuals. Screens read the model; the model does not mirror screens.

**Relationships are first-class and typed.** "An order was placed at a store" is one statement,
`?order ex:placedAt ?store`, that can be followed in both directions, counted, filtered and joined
with any other statement. There is no join table, no parent column and no nullable foreign key.
Every relationship a view needs is either asserted directly or reachable by a property path the
LLD names.

**The entity carries its current facts.** The store, customer, category, dates and flags of an
order are statements on the order. A record node (an approval, an import run, a review) is a
workflow or provenance record. Nothing that reads the graph for its current state hops through a
record node. Reification is for history and provenance only.

**Identity is an opaque IRI.** Minting may derive an IRI from a name or a hash, and input
validation may check an IRI's namespace. Read logic never learns a node's kind from its IRI text;
the kind is `rdf:type`.

**Hierarchies are controlled vocabularies.** Categories, types and other classifications are SKOS
concepts in SKOS schemes. A hierarchy is `skos:broader`, of any depth; the top of a hierarchy is
`skos:topConceptOf` a scheme; a "top-level category" is the top concept reachable through
`skos:broader*`, never "the entry whose parent is null". A concept may belong to more than one
scheme. A second scheme over the same entities (a reporting view, a regulatory view) is new data,
not new code.

**The world is open.** New kinds, new relationships and new schemes are added as ontology
statements and data. The read layer is written so that a new kind costs an ontology entry and one
allow-list line, not edits across every module. If adding a kind needs code in more than two
places, the read layer is table-shaped and should be generalised.

**Standard vocabularies are used, or not declared.** `skos:` for vocabularies, `foaf:` for
persons, `time:` for intervals, `prov:` if provenance is modelled generically. Aligning a project
property to a standard one (`ex:inMonth rdfs:subPropertyOf time:intervalIn`) is worthwhile only
when something queries or infers through the standard property. An alignment nobody reads is
documentation; say so in the ontology comment or remove it.

**Inference is a decision, not an accident.** An axiom such as `rdfs:domain`, `owl:inverseOf` or
`owl:TransitiveProperty` produces derived statements only if the repository runs a ruleset. Without
one the axiom is documentation. Section 2 says how to decide; whichever way, the ontology must not
promise derived facts the reads cannot see.

**Materialise what the store cannot compute.** SPARQL has no date truncation, so calendar periods
are nodes with explicit containment links (day in month, month in year), minted at write time and
shared by every entity of the same day. This is the right pattern for any derived structure a
store cannot evaluate cheaply at read time. Apply it deliberately, with the derivation written in
one place.

---

## 2. Trade-offs to decide and record (Solution Architect)

Each of these is a recorded architectural decision with options, rationale, consequences and
reversibility. None is "obvious".

| Decision | Option A | Option B | What tips it |
|---|---|---|---|
| Derived facts | A repository ruleset (RDFS, RDFS-Plus, OWL-RL) derives inverses, transitive closures and type propagation at write time; reads are shorter and generic | Explicit statements only; every derivation is a named path in the LLD or a materialised node | Write cost and memory on the chosen store; whether reads must be reproducible from explicit statements; how many axioms the model would actually use |
| Current fact placement | On the entity | On a record node, read through a hop | Any fact a view reads goes on the entity. A record node holds who, when and why |
| Read shape | One generic neighbourhood query keyed by `rdf:type` with an allow-list | One query per kind and predicate | Generic unless a kind needs a multi-hop pattern; then that pattern is a named special case inside the generic query |
| Derived structure | Materialised nodes (periods, group keys) written once | Computed in the application on every read | Anything a query must group or filter by is in the graph |
| Identity reach | Local IRIs only | Links to external identifiers (a public knowledge base, an industry register) | Often not needed at first; the model should not make it impossible (a linking property is one statement away) |
| Vocabulary depth | One two-level scheme | Any depth, several schemes | The model and the queries allow any depth if `skos:broader*` is used; code that assumes two levels is a defect, not a decision |

Record in the requirements, per read surface, the round-trip and hop bounds of Section 3.

---

## 3. Graph quality attributes (Solution Architect)

Measurable attributes a graph-backed read surface states. The targets are defaults: a project
adopts them or sets its own in its quality attributes.

| Attribute | Measure | Default target |
|---|---|---|
| Round trips | SPARQL requests per user-visible read | At most one request per concept read (rows, figures, labels folded in), never one per node or per kind; a neighbourhood view at most 2 |
| Hops to a current fact | Triples traversed from the entity to a fact a view shows | 1 for any fact on the entity; each longer path (for example entity to day to month to year) is a named exception |
| Explicit reads | Share of results that depend on inferred statements | 0 unless a decision enables a ruleset, enforced by the client's request, not by repository configuration alone |
| Open-world cost | Code locations touched to add a node kind | The ontology plus one allow-list entry |
| Store safety | Queries that aggregate over the whole repository to answer a single-node question | 0 |

---

## 4. Query rules (Software Architect, Developer)

1. **One request per concept.** A view reads at most: its rows, one neighbourhood query, one
   figures query, and the scope's totals. Labels and kinds come inside those queries, not in
   follow-up lookups.
2. **Restrict before aggregating.** A single node's figures use `VALUES ?node { <iri> }`. Never
   `GROUP BY` every node of a kind and pick one entry out of the result in application code.
3. **Never loop queries over rows.** Collect IRIs, send one query with `VALUES`, chunked (1000 is
   a sound default). A query inside a loop over a previous result is the N+1 pattern and is refused
   at review.
4. **Kind is `rdf:type`.** Bind `?n a ?kind` and allow-list with `VALUES ?kind { … }`. IRI
   namespaces are for validating request input only.
5. **Explicit statements only.** Every read asks the store not to include inferred statements,
   unless a recorded decision enables a ruleset for that read.
6. **Facts from the entity.** A read of an entity's current relationships, classification, dates
   or flags reads the entity. Record nodes are read only by the workflow that owns them.
7. **Hierarchies by path.** `skos:broader*` and `skos:topConceptOf` in the query; a cached
   vocabulary is a label index keyed by IRI, not a structure walked in application code.
8. **Exact sums.** Filters are `EXISTS` / `NOT EXISTS` so they never multiply solution rows. A
   join through a `UNION` or a path that can reach the same entity twice is wrapped in an inner
   `SELECT DISTINCT` over the entity, the node and the value before any `SUM`.
9. **One rendering per pattern.** The scope filter, each named path, the neighbourhood query and
   the figures query each have exactly one function that renders them. A pattern copied into a
   second string is a defect.
10. **Store what you group by.** If the application groups or filters rows by a computed key, the
    key is written to the graph at write time so the query can group by it.
11. **Application code shapes, it does not compute structure.** It turns bindings into the
    response, formats values and sorts. It does not walk hierarchies, derive parents, compute
    roll-ups or reconstruct links from rows.
12. **Query text is built safely.** An IRI reaches a query only through the project's IRI
    validator, text only through its literal escaper, dates and numbers as typed literals. No other
    path builds query text from request data.

---

## 5. Canonical query shapes (Software Architect, Developer)

The shapes use an example vocabulary, `ex:`, for orders placed at stores by customers, classified
in a category scheme and dated by day. Replace the names with the project's; keep the shapes. The
scope restriction is the project's one scope-filter fragment, inserted where the comment says.

**A. Neighbourhood of one node, any kind, one request.** The period path is the named multi-hop
case, expressed as a path, not as a branch per granularity.

```sparql
PREFIX ex:   <http://example.org/vocabulary/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT ?n ?p ?dir ?kind ?label WHERE {
  {
    { <FOCUS> ?p ?n . BIND("out" AS ?dir) }
    UNION
    { ?n ?p <FOCUS> . BIND("in" AS ?dir) }
    UNION
    { # period roll-up: the orders of a month or a year
      ?n ex:onDay/(ex:inMonth|ex:inYear)+ <FOCUS> .
      BIND(ex:inPeriod AS ?p) BIND("in" AS ?dir)
    }
  }
  ?n a ?kind .
  VALUES ?kind { ex:Order ex:Day ex:Month ex:Year ex:Store foaf:Person ex:OrderCategory }
  OPTIONAL { ?n rdfs:label|foaf:name|skos:prefLabel ?label }
  # for ?kind = ex:Order: the scope filter on ?n
}
```

The allow-list is the whole guarantee that internal nodes stay hidden: a rule, a review or a
provenance node has none of these types, so it cannot appear.

**B. Figures for a set of nodes, one request.** The inner `DISTINCT` makes an order count once per
node even when two statements connect them.

```sparql
PREFIX ex:   <http://example.org/vocabulary/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT ?node (SUM(?amount) AS ?total) (COUNT(?order) AS ?count) WHERE {
  { SELECT DISTINCT ?node ?order ?amount WHERE {
      VALUES ?node { <IRI-1> <IRI-2> }
      ?order a ex:Order ; ex:hasAmount ?amount .
      { ?order ?link ?node .
        VALUES ?link { ex:placedAt ex:placedBy ex:hasCategory } }
      UNION { ?order ex:hasCategory/skos:broader+ ?node }
      UNION { ?order ex:onDay/(ex:inMonth|ex:inYear)* ?node }
      FILTER NOT EXISTS { ?order ex:cancelled true }
      # the scope filter here
  } }
} GROUP BY ?node
```

**C. Top-level category of an entity, at any depth.**

```sparql
?order ex:hasCategory/skos:broader* ?top .
?top skos:topConceptOf ex:OrderCategoryScheme .
```

**D. The category tree, one request, for the label index.**

```sparql
PREFIX ex:   <http://example.org/vocabulary/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT ?c ?label ?parent ?top WHERE {
  ?c a ex:OrderCategory ; skos:inScheme ex:OrderCategoryScheme ; skos:prefLabel ?label .
  FILTER(lang(?label) = "en")
  OPTIONAL { ?c skos:broader ?parent }
  ?c skos:broader* ?top . ?top skos:topConceptOf ex:OrderCategoryScheme .
}
```

**E. Scope filter.** One function renders the scope restriction every read shares: a period join
by path, `EXISTS` tests for everything else, no row multiplication.

---

## 6. The graph store (Software Architect, Developer)

Rules that hold for any triple store. The project's values are recorded in its LLD (Section 8).

- **One module talks to the store.** Every read and write goes through the project's store client.
  No other module opens a connection or builds a request.
- **A read returns a result or a typed store error.** Callers check the type; a store failure is
  never an uncaught exception and never reaches the user as raw text.
- **The client asks for explicit statements** on every read (for RDF4J-compatible stores,
  `infer=false`), unless a decision enables inference for that read.
- **A write is one transaction.** Either every statement of a write unit lands or none does. The
  LLD states how many write units and requests may be open at once.
- **One request timeout** for every request. A query that needs longer is wrongly shaped.
- **Memory is finite.** A query that aggregates over the whole repository can exhaust the store.
  Restrict with `VALUES` and the scope filter first; running out of memory is a symptom of an
  unrestricted query, not a reason to avoid `GROUP BY`.
- **Property paths** (`/`, `|`, `*`, `+`, `?`, `^`) are cheap over bounded structures such as a
  period tree or a category tree. Use them instead of a branch per level.
- **Repeatable inputs are chunked** per `VALUES` block.
- **The ontology version is checked.** The repository states the schema version it holds; the
  application compares it with the version it expects before it writes.
- **Tests run against a dedicated test repository only.** No test, script or agent reads or writes
  a repository that holds real data. The test repository may be wiped.

---

## 7. Review checklist (Code Review Agent)

Answer each with yes or no and cite the line. Any "no" is a finding.

1. Does every read ask for explicit statements only, or cite the decision that enables inference for it?
2. Is a node's kind decided from `rdf:type`, never from its IRI prefix, outside input validation?
3. Does a single node's figure query carry `VALUES ?node { <iri> }` rather than grouping the whole kind?
4. Is there no query issued inside a loop over a previous result?
5. Does the view issue at most one request per concept (rows, neighbourhood, figures, totals)?
6. Does every read of an entity's current fact go to the entity, not through a record node?
7. Are hierarchies traversed with `skos:broader*` and `skos:topConceptOf` in SPARQL, not by walking structures in application code?
8. Is every scope or relationship pattern rendered by exactly one function, with no copied string?
9. Does every `SUM` sit over a row set that cannot contain an entity twice (an inner `SELECT DISTINCT` where a `UNION` or a path can duplicate)?
10. Did adding a node kind or relationship touch only the ontology and an allow-list?
11. Does every axiom the ontology change declares either have its derived facts visible to the reads, or carry a comment saying it is documentation only?
12. Do IRIs and text reach SPARQL only through the project's validator and escaper?
13. Does every test touch the test repository only?

---

## 8. Where the project records its facts

This skill holds rules, not project facts, so it can be replaced by a newer version unchanged.

| Fact | Where the project records it |
|---|---|
| The ontology file, its namespace and the schema version the application expects | The data contracts of the low-level design |
| The store product and version, its memory limit, the request timeout, the chunk size, how many requests and write units may be open | The configuration and dependencies of the low-level design |
| The store client module, the one function per pattern (scope filter, named paths, neighbourhood, figures) and the IRI validator and literal escaper | The module boundaries and the read conventions of the low-level design |
| The test repository's name, and the repositories no test may touch | The verification design of the low-level design |
| Inference or explicit statements, fact placement, and each named multi-hop path | Architectural decisions in the decision log |
| The round-trip and hop bounds per read surface | Quality attributes in the requirements |
