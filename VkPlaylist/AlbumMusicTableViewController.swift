//
//  AlbumMusicTableViewController.swift
//  VkPlaylist
//
//  MIT License
//
//  Copyright (c) 2016 Ilya Khalyapin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// Контроллер содержащий таблицу со списком аудиозаписей выбранного плейлиста
class AlbumMusicTableViewController: MusicFromInternetWithSearchTableViewController {
    
    /// Выбранный альбом
    var album: Album!
    
    /// Запрос на получение данных с сервера
    override var getRequest: (() -> Void)! {
        return getAlbumMusic
    }
    /// Статус выполнения запроса к серверу
    override var requestManagerStatus: RequestManagerObject.State {
        return RequestManager.sharedInstance.getAlbumAudio.state
    }
    /// Ошибки при выполнении запроса к серверу
    override var requestManagerError: RequestManagerObject.ErrorRequest {
        return RequestManager.sharedInstance.getAlbumAudio.error
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if VKAPIManager.isAuthorized {
            getRequest()
        }
        
        // Настройка поисковой панели
        searchController.searchBar.placeholder = "Поиск"
    }
    
    
    // MARK: Выполнение запроса на получение аудиозаписей альбома
    
    /// Запрос на получение аудиозаписей альбома с сервера
    func getAlbumMusic() {
        RequestManager.sharedInstance.getAlbumAudio.performRequest([.AlbumID : album.id]) { success in
            self.playlistIdentifier = NSUUID().UUIDString
            
            self.music = DataManager.sharedInstance.albumMusic.array
            
            self.reloadTableView()
            
            if let refreshControl = self.refreshControl {
                if refreshControl.refreshing { // Если данные обновляются
                    refreshControl.endRefreshing() // Говорим что обновление завершено
                }
            }
            
            if !success {
                switch self.requestManagerError {
                case .UnknownError:
                    let alertController = UIAlertController(title: "Ошибка", message: "Произошла какая-то ошибка, попробуйте еще раз...", preferredStyle: .Alert)
                    
                    let okAction = UIAlertAction(title: "ОК", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alertController, animated: false, completion: nil)
                    }
                default:
                    break
                }
            }
        }
    }
    
    
    // MARK: Получение ячеек для строк таблицы helpers
    
    /// Текст для ячейки с сообщением о том, что сервер вернул пустой массив
    override var noResultsLabelText: String {
        return "Альбом пустой"
    }
    
    /// Текст для ячейки с сообщением о том, что при поиске ничего не найдено
    override var textForNothingFoundRow: String {
        return "Измените поисковый запрос"
    }
    
    /// Текст для ячейки с сообщением о необходимости авторизоваться
    override var noAuthorizedLabelText: String {
        return "Необходимо авторизоваться"
    }

}
