dataSource {
    dbCreate = "update" // one of 'create', 'create-drop','update'
	dialect = "org.hibernate.dialect.OracleDialect"
    jndiName = "java:comp/env/jdbc/cmDS"
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}
// environment specific settings
environments {
    development {
    }
    test {
    }
    production {
    }
}
