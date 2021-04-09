/**
 * Provides classes modeling security-relevant aspects of the standard libraries.
 * Note: some modeling is done internally in the dataflow/taint tracking implementation.
 */

private import python
private import semmle.python.dataflow.new.DataFlow
private import semmle.python.dataflow.new.TaintTracking
private import semmle.python.dataflow.new.RemoteFlowSources
private import experimental.semmle.python.Concepts
private import semmle.python.ApiGraphs

private module NoSQL {
  private class PyMongoMethods extends string {
    // These are all find-keyword relevant PyMongo collection level operation methods
    PyMongoMethods() {
      this in [
          "find", "find_raw_batches", "find_one", "find_one_and_delete", "find_and_modify",
          "find_one_and_replace", "find_one_and_update"
        ]
    }
  }

  private class PyMongoClientCall extends DataFlow::CallCfgNode, NoSQLQuery::Range {
    PyMongoClientCall() {
      this =
        API::moduleImport("pymongo")
            .getMember("MongoClient")
            .getReturn()
            .getAMember*()
            .getMember(any(PyMongoMethods pyMongoMethod))
            .getACall()
    }

    override DataFlow::Node getQueryNode() { result = this.getArg(0) }
  }

  private class PyMongoFlaskMethods extends string {
    PyMongoFlaskMethods() { this in ["find_one_or_404", any(PyMongoMethods pyMongoMethod)] }
  }

  private class PyMongoFlaskCall extends DataFlow::CallCfgNode, NoSQLQuery::Range {
    PyMongoFlaskCall() {
      this =
        API::moduleImport("flask_pymongo")
            .getMember("PyMongo")
            .getReturn()
            .getAMember*()
            .getMember(any(PyMongoFlaskMethods pyMongoFlaskMethod))
            .getACall()
    }

    override DataFlow::Node getQueryNode() { result = this.getArg(0) }
  }

  private class MongoEngineObjectsCall extends DataFlow::CallCfgNode, NoSQLQuery::Range {
    MongoEngineObjectsCall() {
      this =
        API::moduleImport("mongoengine")
            .getMember("Document")
            .getASubclass()
            .getMember("objects")
            .getACall()
    }

    override DataFlow::Node getQueryNode() { result = this.getArgByName(any(string name)) }
  }

  private class MongoEngineObjectsFlaskCall extends DataFlow::CallCfgNode, NoSQLQuery::Range {
    MongoEngineObjectsFlaskCall() {
      this =
        API::moduleImport("flask_mongoengine")
            .getMember("MongoEngine")
            .getReturn()
            .getMember("Document")
            .getASubclass()
            .getMember("objects")
            .getACall()
    }

    override DataFlow::Node getQueryNode() { result = this.getArgByName(any(string name)) }
  }

  private class MongoSanitizerCall extends DataFlow::CallCfgNode, NoSQLSanitizer::Range {
    MongoSanitizerCall() {
      this =
        API::moduleImport("mongosanitizer").getMember("sanitizer").getMember("sanitize").getACall()
    }

    override DataFlow::Node getSanitizerNode() { result = this.getArg(0) }
  }
}
