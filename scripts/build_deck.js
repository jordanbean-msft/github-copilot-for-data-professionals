const pptxgen = require("pptxgenjs");
const path = require("path");

const pptx = new pptxgen();
pptx.layout = "LAYOUT_WIDE";
pptx.author = "Jordan Bean";
pptx.company = "Microsoft";
pptx.subject = "GitHub Copilot for data engineers and data scientists";
pptx.title = "GitHub Copilot for Data Professionals";
pptx.lang = "en-US";
pptx.theme = {
  headFontFace: "Segoe UI Semibold",
  bodyFontFace: "Segoe UI",
  lang: "en-US",
};
pptx.defineLayout({ name: "CUSTOM_WIDE", width: 13.6, height: 7.6 });
pptx.layout = "CUSTOM_WIDE";

const COLORS = {
  navy: "000041",
  blue: "0078D3",
  cyan: "50E6FF",
  gray: "EBEBEB",
  midGray: "75757A",
  black: "000000",
  white: "FFFFFF",
  green: "107C10",
  orange: "F7630C",
};

const OUT = path.join(__dirname, "..", "deck", "github-copilot-for-data-professionals.pptx");
const MASTER_NAME = "MSFT_BRAND_MASTER";

pptx.defineSlideMaster({
  title: MASTER_NAME,
  objects: [
    { rect: { x: 11.44, y: 7.17, w: 0.07, h: 0.07, fill: { color: "F25022" }, line: { color: "F25022", transparency: 100 } } },
    { rect: { x: 11.53, y: 7.17, w: 0.07, h: 0.07, fill: { color: "7FBA00" }, line: { color: "7FBA00", transparency: 100 } } },
    { rect: { x: 11.44, y: 7.26, w: 0.07, h: 0.07, fill: { color: "00A4EF" }, line: { color: "00A4EF", transparency: 100 } } },
    { rect: { x: 11.53, y: 7.26, w: 0.07, h: 0.07, fill: { color: "FFB900" }, line: { color: "FFB900", transparency: 100 } } },
    { text: { text: "Microsoft", options: { x: 11.64, y: 7.15, w: 1.2, h: 0.2, fontFace: "Segoe UI", fontSize: 8, color: COLORS.midGray, margin: 0 } } },
  ],
});

function addNotes(slide, notes) {
  if (typeof slide.addNotes === "function") {
    slide.addNotes(notes);
  }
}

function title(slide, text, subtitle) {
  slide.addText(text, {
    x: 0.55,
    y: 0.28,
    w: 9.8,
    h: 0.52,
    fontFace: "Segoe UI Semibold",
    fontSize: 28,
    color: COLORS.navy,
    margin: 0,
    fit: "shrink",
  });
  slide.addShape(pptx.ShapeType.rect, { x: 0.55, y: 0.93, w: 1.0, h: 0.06, fill: { color: COLORS.blue }, line: { color: COLORS.blue } });
  if (subtitle) {
    slide.addText(subtitle, { x: 10.25, y: 0.35, w: 2.7, h: 0.25, fontSize: 8.5, color: COLORS.midGray, align: "right", margin: 0 });
  }
}

function sectionNumber(slide, n, label) {
  slide.addShape(pptx.ShapeType.ellipse, { x: 0.63, y: 1.34, w: 0.52, h: 0.52, fill: { color: COLORS.blue }, line: { color: COLORS.blue } });
  slide.addText(String(n).padStart(2, "0"), { x: 0.63, y: 1.47, w: 0.52, h: 0.2, fontSize: 9, bold: true, color: COLORS.white, align: "center", margin: 0 });
  slide.addText(label, { x: 1.32, y: 1.44, w: 5.8, h: 0.25, fontSize: 12, color: COLORS.midGray, margin: 0 });
}

function addCard(slide, x, y, w, h, label, body, color = COLORS.blue) {
  slide.addShape(pptx.ShapeType.roundRect, {
    x, y, w, h,
    rectRadius: 0.08,
    fill: { color: COLORS.white },
    line: { color: "D8D8D8", width: 1 },
  });
  slide.addShape(pptx.ShapeType.ellipse, { x: x + 0.18, y: y + 0.18, w: 0.42, h: 0.42, fill: { color }, line: { color } });
  slide.addText(label, { x: x + 0.75, y: y + 0.18, w: w - 0.95, h: 0.28, fontFace: "Segoe UI Semibold", fontSize: 13, color: COLORS.navy, margin: 0 });
  slide.addText(body, { x: x + 0.75, y: y + 0.58, w: w - 0.95, h: h - 0.75, fontSize: 10.5, color: COLORS.black, margin: 0.02, fit: "shrink" });
}

function addFlowStep(slide, x, y, number, label, body) {
  slide.addShape(pptx.ShapeType.ellipse, { x, y, w: 0.58, h: 0.58, fill: { color: COLORS.blue }, line: { color: COLORS.blue } });
  slide.addText(String(number), { x, y: y + 0.14, w: 0.58, h: 0.2, fontSize: 13, bold: true, color: COLORS.white, align: "center", margin: 0 });
  slide.addText(label, { x: x + 0.78, y: y - 0.02, w: 2.05, h: 0.3, fontSize: 13, bold: true, color: COLORS.navy, margin: 0 });
  slide.addText(body, { x: x + 0.78, y: y + 0.36, w: 2.25, h: 0.54, fontSize: 9.5, color: COLORS.black, margin: 0 });
}

function addDemoRibbon(slide, text) {
  slide.addShape(pptx.ShapeType.roundRect, { x: 9.85, y: 1.15, w: 2.85, h: 0.38, fill: { color: COLORS.navy }, line: { color: COLORS.navy } });
  slide.addText(text, { x: 10.05, y: 1.25, w: 2.45, h: 0.13, fontSize: 8.5, color: COLORS.white, bold: true, align: "center", margin: 0 });
}

// 1
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.navy };
  slide.addText("GitHub Copilot for Data Professionals", { x: 0.75, y: 1.25, w: 9.8, h: 1.0, fontSize: 44, color: COLORS.white, bold: true, margin: 0, fit: "shrink" });
  slide.addText("Not just for software developers - for everyone who writes code", { x: 0.78, y: 2.55, w: 8.8, h: 0.42, fontSize: 19, color: COLORS.cyan, margin: 0 });
  slide.addText("Jordan Bean\nPrincipal Cloud & AI Apps Solution Engineer\n30-minute public presentation + live Microsoft Fabric demo kit", { x: 0.78, y: 5.55, w: 7.9, h: 0.78, fontSize: 14, color: COLORS.white, breakLine: false, margin: 0.02 });
  slide.addShape(pptx.ShapeType.arc, { x: 9.85, y: 1.0, w: 2.2, h: 2.2, line: { color: COLORS.cyan, width: 3, beginArrowType: "none", endArrowType: "none" }, adjustPoint: 0.25 });
  slide.addShape(pptx.ShapeType.roundRect, { x: 9.25, y: 3.15, w: 3.35, h: 1.52, fill: { color: COLORS.blue }, line: { color: COLORS.blue } });
  slide.addText("Data Engineering\nData Science\nAnalytics Engineering", { x: 9.55, y: 3.48, w: 2.75, h: 0.78, fontSize: 18, bold: true, color: COLORS.white, align: "center", margin: 0 });
  addNotes(slide, "Open with the core thesis: Copilot is not a developer-only productivity tool. Data professionals write code constantly - notebooks, SQL, PySpark, Python, tests, YAML, documentation and operational runbooks. The value is reducing friction across that daily coding surface while keeping the data professional in control.");
}

// 2
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "The Thesis", "Why this matters");
  sectionNumber(slide, 0, "Frame the opportunity");
  slide.addText("Copilot helps data teams move from blank page to validated workflow faster", { x: 1.25, y: 2.0, w: 8.2, h: 0.66, fontSize: 28, bold: true, color: COLORS.navy, margin: 0, fit: "shrink" });
  addCard(slide, 1.25, 3.05, 3.3, 1.25, "Code is everywhere", "Python notebooks, PySpark jobs, SQL queries, tests, deployment scripts, documentation", COLORS.blue);
  addCard(slide, 5.0, 3.05, 3.3, 1.25, "The bottleneck is context", "Understanding schemas, APIs, patterns and edge cases slows delivery", COLORS.cyan);
  addCard(slide, 8.75, 3.05, 3.3, 1.25, "Expertise still leads", "Copilot drafts and explains; humans validate meaning, quality, governance and risk", COLORS.green);
  slide.addShape(pptx.ShapeType.chevron, { x: 2.5, y: 5.2, w: 1.1, h: 0.6, fill: { color: COLORS.gray }, line: { color: COLORS.gray } });
  slide.addShape(pptx.ShapeType.chevron, { x: 4.2, y: 5.2, w: 1.1, h: 0.6, fill: { color: COLORS.blue }, line: { color: COLORS.blue } });
  slide.addShape(pptx.ShapeType.chevron, { x: 5.9, y: 5.2, w: 1.1, h: 0.6, fill: { color: COLORS.cyan }, line: { color: COLORS.cyan } });
  slide.addShape(pptx.ShapeType.chevron, { x: 7.6, y: 5.2, w: 1.1, h: 0.6, fill: { color: COLORS.green }, line: { color: COLORS.green } });
  slide.addText("Understand -> Generate -> Refine -> Document", { x: 2.1, y: 6.05, w: 7.0, h: 0.3, fontSize: 18, bold: true, color: COLORS.navy, align: "center", margin: 0 });
  addNotes(slide, "Emphasize that the value is not replacing judgment. It is improving the speed at which a data professional can explore, draft, test and document. That is especially relevant in Fabric where teams often move among Python, Spark, SQL, notebooks and lakehouse concepts in the same workflow.");
}

// 3
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "Agenda");
  const items = [
    ["00", "Why Copilot for data professionals"],
    ["01", "Microsoft Fabric demo architecture"],
    ["02", "Live data engineering workflows"],
    ["03", "Live data science workflows"],
    ["04", "Prompt patterns, governance & measurement"],
  ];
  items.forEach((item, idx) => {
    const y = 1.65 + idx * 0.92;
    slide.addText(item[0], { x: 1.0, y, w: 0.75, h: 0.42, fontSize: 21, bold: true, color: COLORS.blue, margin: 0 });
    slide.addText(item[1], { x: 1.95, y: y + 0.04, w: 7.8, h: 0.33, fontSize: 19, color: COLORS.navy, margin: 0 });
    slide.addShape(pptx.ShapeType.line, { x: 1.95, y: y + 0.55, w: 8.7, h: 0, line: { color: "DDDDDD", width: 1 } });
  });
  slide.addShape(pptx.ShapeType.roundRect, { x: 10.05, y: 1.58, w: 2.25, h: 4.65, fill: { color: COLORS.navy }, line: { color: COLORS.navy } });
  slide.addText("30\nminutes", { x: 10.35, y: 2.65, w: 1.65, h: 1.35, fontSize: 38, bold: true, color: COLORS.white, align: "center", margin: 0 });
  slide.addText("Story + live demo", { x: 10.35, y: 4.25, w: 1.65, h: 0.3, fontSize: 11, color: COLORS.cyan, align: "center", margin: 0 });
  addNotes(slide, "Set expectations: this is a compact story plus live demo. The deck should move quickly. The credibility comes from the hands-on examples, not a long feature tour.");
}

// 4
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.gray };
  title(slide, "Where Data Teams Write Code");
  const cards = [
    ["Ingest", "connectors, files, schemas, bronze tables"],
    ["Profile", "missing values, distribution, anomalies"],
    ["Validate", "rules, tests, quarantine logic"],
    ["Transform", "PySpark, SQL, Delta tables"],
    ["Analyze", "business questions, reusable queries"],
    ["Model", "features, experiments, interpretation"],
  ];
  cards.forEach((card, idx) => {
    const col = idx % 3;
    const row = Math.floor(idx / 3);
    addCard(slide, 0.95 + col * 4.05, 1.55 + row * 1.65, 3.45, 1.22, card[0], card[1], idx % 2 === 0 ? COLORS.blue : COLORS.cyan);
  });
  slide.addText("Copilot participates across the whole workflow - not only application code", { x: 1.15, y: 5.25, w: 10.9, h: 0.48, fontSize: 23, bold: true, color: COLORS.navy, align: "center", margin: 0 });
  addNotes(slide, "Use this slide to broaden the audience. Data engineers and scientists often do not identify as software developers, but they absolutely write code. Copilot can help with every repeated task in this map.");
}

// 5
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "Demo Architecture", "Microsoft Fabric + GitHub");
  const x0 = 0.8;
  const y = 2.05;
  const components = [
    ["GitHub repo", "prompts, notebooks, SQL, scripts"],
    ["VS Code + Copilot", "chat, inline suggestions, explain"],
    ["Fabric notebook", "PySpark, pandas, lakehouse"],
    ["Lakehouse", "Files, Delta tables, SQL endpoint"],
    ["Power BI", "semantic model, reporting"],
  ];
  components.forEach((c, i) => {
    const x = x0 + i * 2.45;
    slide.addShape(pptx.ShapeType.roundRect, { x, y, w: 1.9, h: 1.1, fill: { color: i % 2 ? COLORS.gray : "F6FBFF" }, line: { color: COLORS.blue, width: 1.2 } });
    slide.addText(c[0], { x: x + 0.12, y: y + 0.16, w: 1.66, h: 0.22, fontSize: 12, bold: true, color: COLORS.navy, align: "center", margin: 0 });
    slide.addText(c[1], { x: x + 0.14, y: y + 0.52, w: 1.62, h: 0.38, fontSize: 8.2, color: COLORS.black, align: "center", margin: 0, fit: "shrink" });
    if (i < components.length - 1) {
      slide.addShape(pptx.ShapeType.line, { x: x + 1.95, y: y + 0.55, w: 0.45, h: 0, line: { color: COLORS.blue, width: 2, beginArrowType: "none", endArrowType: "triangle" } });
    }
  });
  slide.addShape(pptx.ShapeType.roundRect, { x: 1.15, y: 4.45, w: 10.7, h: 1.05, fill: { color: COLORS.navy }, line: { color: COLORS.navy } });
  slide.addText("Live demo uses synthetic data only: sales orders + industrial sensor telemetry", { x: 1.45, y: 4.78, w: 10.1, h: 0.34, fontSize: 18, bold: true, color: COLORS.white, align: "center", margin: 0 });
  addNotes(slide, "The architecture is deliberately simple. The goal is to show Copilot helping with the coding surfaces around Fabric, not to teach a complex reference architecture. The examples can be run locally or imported into Fabric notebooks.");
}

// 6
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.navy };
  slide.addText("01", { x: 0.85, y: 1.0, w: 1.0, h: 0.45, fontSize: 22, bold: true, color: COLORS.cyan, margin: 0 });
  slide.addText("Live Demo - Generate & Ingest", { x: 0.85, y: 1.65, w: 9.2, h: 0.66, fontSize: 38, bold: true, color: COLORS.white, margin: 0 });
  slide.addText("From blank page to repeatable synthetic data", { x: 0.9, y: 2.62, w: 7.2, h: 0.35, fontSize: 18, color: COLORS.cyan, margin: 0 });
  slide.addShape(pptx.ShapeType.roundRect, { x: 8.2, y: 1.55, w: 3.8, h: 2.4, fill: { color: COLORS.white }, line: { color: COLORS.cyan, width: 1.2 } });
  slide.addText("Prompt", { x: 8.5, y: 1.88, w: 1.0, h: 0.2, fontSize: 11, bold: true, color: COLORS.blue, margin: 0 });
  slide.addText("Explain this data generator and add one realistic bad-data condition that a data engineer should catch.", { x: 8.5, y: 2.25, w: 3.2, h: 0.92, fontSize: 13, color: COLORS.navy, margin: 0.02, fit: "shrink" });
  slide.addText("Run: python examples\\python\\00_generate_sample_data.py", { x: 0.9, y: 5.65, w: 8.2, h: 0.26, fontSize: 13, color: COLORS.white, margin: 0 });
  addNotes(slide, "Demo the first workflow in VS Code. Open the generator, ask Copilot to explain it, then ask for a new bad-data condition such as duplicate order IDs or sensor clock skew. The teaching point is that data teams constantly build fixtures and test data, and Copilot accelerates the first draft plus edge-case thinking.");
}

// 7
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "Profile & Understand Data");
  addDemoRibbon(slide, "Demo file 01");
  addFlowStep(slide, 1.0, 1.8, 1, "Load", "Read CSV or Lakehouse files");
  addFlowStep(slide, 4.2, 1.8, 2, "Profile", "Types, missing values, cardinality");
  addFlowStep(slide, 7.4, 1.8, 3, "Explain", "Ask Copilot for risk signals");
  addFlowStep(slide, 10.6, 1.8, 4, "Reuse", "Package helper functions");
  slide.addShape(pptx.ShapeType.roundRect, { x: 1.05, y: 4.1, w: 11.1, h: 1.05, fill: { color: "F6FBFF" }, line: { color: COLORS.blue } });
  slide.addText("Copilot prompt", { x: 1.32, y: 4.36, w: 1.6, h: 0.2, fontSize: 11, bold: true, color: COLORS.blue, margin: 0 });
  slide.addText("Generate three data quality rules from this profile and explain why each matters.", { x: 3.0, y: 4.32, w: 8.7, h: 0.26, fontSize: 16, color: COLORS.navy, margin: 0 });
  addNotes(slide, "Show that Copilot is useful before you know the answer. Profiling is a discovery task. Ask Copilot to interpret the profile and suggest next actions, then challenge it to turn those suggestions into concrete validation code.");
}

// 8
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "Quality Checks & Quarantine");
  addDemoRibbon(slide, "Demo file 02");
  addCard(slide, 0.95, 1.55, 3.4, 1.35, "Required fields", "Missing or blank region, device, product and event fields", COLORS.blue);
  addCard(slide, 4.9, 1.55, 3.4, 1.35, "Range checks", "Invalid discounts, negative vibration, impossible temperatures", COLORS.orange);
  addCard(slide, 8.85, 1.55, 3.4, 1.35, "Quarantine", "Failed rows with reason codes for triage and replay", COLORS.green);
  slide.addShape(pptx.ShapeType.roundRect, { x: 1.2, y: 4.05, w: 10.65, h: 1.18, fill: { color: COLORS.navy }, line: { color: COLORS.navy } });
  slide.addText("Copilot turns natural-language expectations into repeatable code - but the data owner validates the rules", { x: 1.55, y: 4.42, w: 9.95, h: 0.3, fontSize: 17, bold: true, color: COLORS.white, align: "center", margin: 0 });
  addNotes(slide, "This is a strong data-engineering moment. Show Copilot generating checks, then ask it to improve them by returning failed rows with reasons. Stress that Copilot can draft the mechanics, but the human decides whether the rule is correct for the domain.");
}

// 9
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.gray };
  title(slide, "Transform in Fabric");
  addDemoRibbon(slide, "Demo file 03");
  slide.addShape(pptx.ShapeType.roundRect, { x: 0.95, y: 1.55, w: 5.15, h: 4.0, fill: { color: COLORS.white }, line: { color: "D8D8D8" } });
  slide.addText("Pandas-first thinking", { x: 1.25, y: 1.88, w: 3.4, h: 0.3, fontSize: 18, bold: true, color: COLORS.navy, margin: 0 });
  slide.addText("groupby\nfilter invalid rows\naggregate revenue\nsummarize device health", { x: 1.4, y: 2.45, w: 3.8, h: 1.2, fontSize: 15, color: COLORS.black, breakLine: false, margin: 0.05, bullet: { type: "ul" } });
  slide.addShape(pptx.ShapeType.line, { x: 6.35, y: 3.45, w: 1.1, h: 0, line: { color: COLORS.blue, width: 3, endArrowType: "triangle" } });
  slide.addShape(pptx.ShapeType.roundRect, { x: 7.7, y: 1.55, w: 5.15, h: 4.0, fill: { color: "F6FBFF" }, line: { color: COLORS.blue } });
  slide.addText("Fabric-ready PySpark", { x: 8.0, y: 1.88, w: 3.6, h: 0.3, fontSize: 18, bold: true, color: COLORS.navy, margin: 0 });
  slide.addText("Lakehouse files\nSpark SQL temp views\nDelta table write path\nSQL endpoint ready", { x: 8.15, y: 2.45, w: 3.8, h: 1.2, fontSize: 15, color: COLORS.black, breakLine: false, margin: 0.05, bullet: { type: "ul" } });
  addNotes(slide, "Ask Copilot to convert a pandas aggregation into PySpark. The important moment is not merely syntax translation - ask it to explain where a Fabric lakehouse table should be written and how this supports downstream SQL and reporting.");
}

// 10
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "SQL From Business Questions");
  addDemoRibbon(slide, "Demo file 04");
  slide.addShape(pptx.ShapeType.roundRect, { x: 0.85, y: 1.55, w: 4.0, h: 4.3, fill: { color: COLORS.navy }, line: { color: COLORS.navy } });
  slide.addText("Business question", { x: 1.15, y: 1.95, w: 3.4, h: 0.3, fontSize: 17, bold: true, color: COLORS.cyan, margin: 0 });
  slide.addText("Which products are growing by region, and where is demand declining?", { x: 1.15, y: 2.65, w: 3.3, h: 1.1, fontSize: 21, bold: true, color: COLORS.white, margin: 0.02, fit: "shrink" });
  addFlowStep(slide, 5.55, 1.75, 1, "Draft", "Generate SQL from intent");
  addFlowStep(slide, 5.55, 3.05, 2, "Explain", "Validate joins and windows");
  addFlowStep(slide, 5.55, 4.35, 3, "Optimize", "Indexes, filters, aggregations");
  addFlowStep(slide, 9.05, 3.05, 4, "Document", "Lineage and assumptions");
  addNotes(slide, "This is where analytics engineers and data analysts see themselves in the story. Ask Copilot to write SQL from the business question, then ask it to explain the query and identify assumptions. That second step is how you keep the demo from looking like blind code generation.");
}

// 11
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.navy };
  slide.addText("02", { x: 0.85, y: 1.0, w: 1.0, h: 0.45, fontSize: 22, bold: true, color: COLORS.cyan, margin: 0 });
  slide.addText("Live Demo - Features & Models", { x: 0.85, y: 1.65, w: 9.2, h: 0.66, fontSize: 38, bold: true, color: COLORS.white, margin: 0 });
  slide.addText("From telemetry to maintenance-risk signals", { x: 0.9, y: 2.62, w: 7.2, h: 0.35, fontSize: 18, color: COLORS.cyan, margin: 0 });
  addCard(slide, 1.05, 4.05, 3.45, 1.15, "Feature ideation", "Ask for candidate features and leakage risks", COLORS.cyan);
  addCard(slide, 5.05, 4.05, 3.45, 1.15, "Model scaffold", "Train/test split, baseline model, metrics", COLORS.blue);
  addCard(slide, 9.05, 4.05, 3.45, 1.15, "Interpretation", "Explain feature importance and next experiments", COLORS.green);
  addNotes(slide, "Transition to the data science workflow. Copilot helps create a quick baseline model, but the real value is also in feature ideation, experiment scaffolding and interpreting the output in plain language.");
}

// 12
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "Prompt Patterns That Work");
  const prompts = [
    ["Role + context", "You are a Fabric data engineer working with Lakehouse tables..."],
    ["Input + output", "Given this schema, return PySpark code and a short explanation..."],
    ["Constraints", "Avoid collecting to driver; handle nulls; keep functions testable..."],
    ["Verification", "Add tests, edge cases and explain how to validate the result..."],
  ];
  prompts.forEach((p, i) => addCard(slide, 0.95 + (i % 2) * 6.0, 1.55 + Math.floor(i / 2) * 1.65, 5.25, 1.2, p[0], p[1], i % 2 ? COLORS.cyan : COLORS.blue));
  slide.addText("Best demo move: ask Copilot to critique its first answer", { x: 1.15, y: 5.35, w: 10.7, h: 0.32, fontSize: 21, bold: true, color: COLORS.navy, align: "center", margin: 0 });
  addNotes(slide, "Do not over-index on magic prompts. Teach a simple pattern: role, context, expected output, constraints and verification. The most compelling moment is asking Copilot to critique or test its own draft.");
}

// 13
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.gray };
  title(slide, "Responsible Data Workflows");
  addCard(slide, 0.95, 1.55, 3.6, 1.35, "Data protection", "Use synthetic or approved data in demos; avoid secrets and sensitive files", COLORS.blue);
  addCard(slide, 4.95, 1.55, 3.6, 1.35, "Human validation", "Review generated code for correctness, cost, privacy and bias", COLORS.green);
  addCard(slide, 8.95, 1.55, 3.6, 1.35, "Production controls", "Use PR reviews, tests, lineage, monitoring and policy gates", COLORS.orange);
  slide.addShape(pptx.ShapeType.roundRect, { x: 1.45, y: 4.25, w: 9.8, h: 1.0, fill: { color: COLORS.white }, line: { color: COLORS.blue } });
  slide.addText("Copilot accelerates coding. Your engineering standards still decide what ships.", { x: 1.85, y: 4.58, w: 9.0, h: 0.26, fontSize: 18, bold: true, color: COLORS.navy, align: "center", margin: 0 });
  addNotes(slide, "This is important for a public audience. Make it clear that Copilot should operate inside existing data governance, security and software delivery controls. It is not a shortcut around review.");
}

// 14
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.white };
  title(slide, "Measuring Value");
  const metrics = [
    ["Time to first draft", "How quickly a pipeline, query, or notebook starts working"],
    ["Review quality", "More tests, clearer explanations, fewer hidden assumptions"],
    ["Reuse", "Shared helpers, templates, prompts and notebook patterns"],
    ["Adoption", "Copilot metrics, active users, chat usage, PR and IDE signals"],
  ];
  metrics.forEach((m, i) => addCard(slide, 0.95 + i * 3.05, 1.75, 2.65, 2.4, m[0], m[1], [COLORS.blue, COLORS.cyan, COLORS.green, COLORS.orange][i]));
  slide.addText("Pair usage telemetry with outcome stories from real data workflows", { x: 1.25, y: 5.3, w: 10.6, h: 0.32, fontSize: 21, bold: true, color: COLORS.navy, align: "center", margin: 0 });
  addNotes(slide, "Reference the idea of measuring both usage and outcomes. Metrics can show adoption, but the best executive story pairs telemetry with concrete data-team examples: fewer repetitive tasks, faster notebook creation, more consistent tests and better documentation.");
}

// 15
{
  const slide = pptx.addSlide({ masterName: MASTER_NAME });
  slide.background = { color: COLORS.navy };
  slide.addText("Call to Action", { x: 0.85, y: 1.1, w: 8.3, h: 0.65, fontSize: 40, bold: true, color: COLORS.white, margin: 0 });
  slide.addText("Start with one workflow your data team repeats every week", { x: 0.88, y: 2.05, w: 8.8, h: 0.42, fontSize: 20, color: COLORS.cyan, margin: 0 });
  addCard(slide, 1.0, 3.05, 3.2, 1.25, "Pick", "A common notebook, SQL query, or quality check", COLORS.cyan);
  addCard(slide, 5.0, 3.05, 3.2, 1.25, "Prompt", "Use role, context, constraints and verification", COLORS.blue);
  addCard(slide, 9.0, 3.05, 3.2, 1.25, "Measure", "Track saved time, quality, reuse and adoption", COLORS.green);
  addNotes(slide, "Close with a practical ask. Do not ask the audience to transform everything at once. Ask them to pick one repeated workflow and use Copilot there with clear measurement and review.");
}

pptx.writeFile({ fileName: OUT }).then(() => {
  console.log(`Wrote ${OUT}`);
});
