<?php

namespace App\Library\Paginator\Adapter;

use Phalcon\Http\Request as HttpRequest;
use Phalcon\Paginator\Adapter as PaginatorAdapter;
use Phalcon\Paginator\Exception as PaginatorException;

/**
 *
 * Pagination using xunsearch as source of data
 *
 * <code>
 * use App\Library\Paginator\Adapter\XunSearch;
 *
 * $paginator = new XunSearch(
 *     [
 *         "xs"  => $xs,
 *         "query"  => $query,
 *         "highlight"  => $highlight,
 *         "page"  => $page,
 *         "limit" => $limit,
 *     ]
 * );
 *</code>
 */
class XunSearch extends PaginatorAdapter
{

    protected $config;

    protected $url;

    protected $params = [];

    public function __construct(array $config)
    {
        if (!isset($config['xs']) || ($config['xs'] instanceof \XS) == false) {
            throw new PaginatorException('Invalid xs parameter');
        }

        if (empty($config['query'])) {
            throw new PaginatorException('Invalid query parameter');
        }

        if (empty($config['page']) || $config['page'] != intval($config['page'])) {
            throw new PaginatorException('Invalid page parameter');
        }

        if (empty($config['limit']) || $config['limit'] != intval($config['limit'])) {
            throw new PaginatorException('Invalid limit parameter');
        }

        if (isset($config['highlight']) && !is_array($config['highlight'])) {
            throw new PaginatorException('Invalid highlight parameter');
        }

        $this->config = $config;
        $this->_page = $config['page'] ?? 1;
        $this->_limitRows = $config['limit'] ?? 15;
    }

    public function paginate()
    {
        /**
         * @var \XS $xs
         */
        $xs = $this->config['xs'];

        $page = $this->_page;
        $limit = $this->_limitRows;
        $offset = ($page - 1) * $limit;

        $search = $xs->getSearch();

        $docs = $search->setQuery($this->config['query'])
            ->setLimit($limit, $offset)
            ->search();

        $totalCount = $search->getLastCount();

        $fields = array_keys($xs->getAllFields());

        $items = [];

        foreach ($docs as $doc) {
            $item = [];
            foreach ($fields as $field) {
                if (in_array($field, $this->config['highlight'])) {
                    $item[$field] = $search->highlight($doc->{$field});
                } else {
                    $item[$field] = $doc->{$field};
                }
            }
            $items[] = $item;
        }

        $totalPages = ceil($totalCount / $limit);

        $pager = new \stdClass();

        $pager->first = 1;
        $pager->previous = $page > 1 ? $page - 1 : 1;
        $pager->next = $page < $totalPages ? $page + 1 : $page;
        $pager->last = $totalPages;
        $pager->total_items = $totalCount;
        $pager->items = $items;

        $this->initParams();

        $pager->first = $this->buildPageUrl($pager->first);
        $pager->previous = $this->buildPageUrl($pager->previous);
        $pager->next = $this->buildPageUrl($pager->next);
        $pager->last = $this->buildPageUrl($pager->last);

        return $pager;
    }

    public function getPaginate()
    {
        return $this->paginate();
    }

    protected function initParams()
    {
        $request = new HttpRequest();

        $params = $request->get();

        if ($params) {
            foreach ($params as $key => $value) {
                if (strlen($value) == 0) {
                    unset($params[$key]);
                }
            }
        }

        $this->params = $params;

        if (!empty($this->params['_url'])) {
            $this->url = $this->params['_url'];
            unset($this->params['_url']);
        } else {
            $this->url = $request->get('_url');
        }
    }

    protected function buildPageUrl($page)
    {
        $this->params['page'] = $page;

        return $this->url . '?' . http_build_query($this->params);
    }

}